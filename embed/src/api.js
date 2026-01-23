const CPO = "https://pyret-horizon.herokuapp.com/editor#controlled=true&footerStyle=hide&warnOnExit=false";
function makeEmbed(id, container, src) {
    let messageNumber = 0;
    let currentState;
    function sendReset(frame, state) {
        if (!state) {
            state = {
                definitionsAtLastRun: false,
                interactionsSinceLastRun: [],
                editorContents: "use context starter2024",
                replContents: ""
            };
        }
        state.messageNumber = 0;
        currentState = state;
        const payload = {
            data: {
                type: 'reset',
                state: typeof state === "string" ? state : JSON.stringify(state)
            },
            protocol: 'pyret'
        };
        frame.contentWindow.postMessage(payload, '*');
    }
    function gainControl(frame) {
        frame.contentWindow.postMessage({
            type: 'gainControl'
        }, '*');
    }
    function setInteractions(frame, text) {
        messageNumber += 1;
        const change = {
            from: { line: 0, ch: 0 },
            to: { line: 0, ch: 0 },
            text: text
        };
        currentState = { ...currentState, messageNumber, replContents: text };
        const payload = {
            protocol: 'pyret',
            data: {
                type: 'changeRepl',
                change: change
            },
            state: currentState
        };
        frame.contentWindow.postMessage(payload, '*');
    }
    function runDefinitions(frame) {
        messageNumber += 1;
        currentState = { ...currentState, messageNumber, interactionsSinceLastRun: [], definitionsAtLastRun: currentState.editorContents };
        const payload = {
            protocol: 'pyret',
            data: {
                type: 'run'
            },
            state: currentState
        };
        frame.contentWindow.postMessage(payload, '*');
    }
    function clearInteractions(frame) {
        messageNumber += 1;
        const payload = {
            protocol: 'pyret',
            data: {
                type: 'clearInteractions'
            },
            state: currentState
        };
        frame.contentWindow.postMessage(payload, '*');
    }
    let resultCounter = 0;
    function runInteractionResult(frame) {
        const { promise, resolve, reject } = Promise.withResolvers();
        messageNumber += 1;
        const newInteractions = currentState.interactionsSinceLastRun.concat([currentState.replContents]);
        currentState = {
            ...currentState,
            messageNumber: messageNumber,
            interactionsSinceLastRun: newInteractions,
            replContents: "",
        };
        const payload = {
            protocol: 'pyret',
            data: {
                type: 'runInteraction',
                reportAnswer: 'interaction' + (++resultCounter)
            },
            state: currentState
        };
        frame.contentWindow.postMessage(payload, '*');
        window.addEventListener('message', message => {
            if (message.data.protocol !== 'pyret') {
                return;
            }
            if (message.source !== frame.contentWindow) {
                return;
            }
            const pyretMessage = message.data;
            if (pyretMessage.data.type === 'interactionResult') {
                resolve(pyretMessage.data.textResult);
            }
        });
        return promise;
    }
    function directPostMessage(frame, message) {
        frame.contentWindow.postMessage(message);
    }
    const frame = document.createElement("iframe");
    frame.id = id;
    frame.src = src || CPO;
    frame.style = "width: 100%; height: 100%; border: 0; display: block;";
    frame.width = "100%";
    frame.frameBorder = "0";
    container.appendChild(frame);
    const { promise, resolve, reject } = Promise.withResolvers();
    setTimeout(() => reject(new Error("Timeout waiting for Pyret to load")), 60000);
    const onChangeCallbacks = [];
    window.addEventListener('message', message => {
        if (message.data.protocol !== 'pyret') {
            return;
        }
        if (message.source !== frame.contentWindow) {
            return;
        }
        const pyretMessage = message.data;
        const typ = pyretMessage.data.type;
        if (typ === 'pyret-init') {
            console.log("Sending gainControl", pyretMessage);
            gainControl(frame);
            resolve(makeEmbedAPI(frame));
        }
        else if (typ === "changeRepl" || typ === "change") {
            onChangeCallbacks.forEach(cb => cb(pyretMessage));
            currentState = pyretMessage.state;
        }
        else {
            currentState = pyretMessage.state;
        }
    });
    function makeEmbedAPI(frame) {
        return {
            sendReset: (state) => sendReset(frame, state),
            postMessage: (message) => directPostMessage(frame, message),
            getFrame: () => frame,
            setInteractions: (text) => setInteractions(frame, text),
            runDefinitions: () => runDefinitions(frame),
            runInteractionResult: async () => await runInteractionResult(frame),
            onChange: (callback) => onChangeCallbacks.push(callback),
            clearInteractions: () => clearInteractions(frame)
        };
    }
    return promise;
}
