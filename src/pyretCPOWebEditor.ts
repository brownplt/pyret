import * as vscode from 'vscode';
import * as path from 'path';
import { URI, Utils } from 'vscode-uri';
import { Buffer } from 'buffer';
import { render } from 'mustache';
const code = require('../build/web/views/editor.html');

// import * as fs from 'fs';
// import * as path from 'path';

export function getNonce() {
  let text = '';
  const possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';
  for (let i = 0; i < 32; i++) {
    text += possible.charAt(Math.floor(Math.random() * possible.length));
  }
  return text;
}

// We support a small subset of the actual fs opts, which we grow as needed
type ReadFileOpts =
    'utf8'
  | { encoding?: 'utf8' };


export function makeCommandHandler(context: vscode.ExtensionContext) {
  const repls = new Map<string, PyretPane>();
  return async (...args : any[]) => {
    const activeEditor = vscode.window.activeTextEditor;
    if (activeEditor) {
      const uri = activeEditor.document.uri.toString();
      console.log("Active editor URI: ", uri);
      console.log("Repls: ", repls);
      if (repls.has(uri)) {
        console.log("A REPL for this document already exists.");
        const repl = repls.get(uri)!;
        repl.pane.reveal(vscode.ViewColumn.Two);
        repl.reset();
        return;
      }
      else {
        const document = activeEditor.document;
        const panel = vscode.window.createWebviewPanel(
          `pyretRun-${document.uri.toString()}`,
          `Run ${document.fileName}`,
          vscode.ViewColumn.Two,
          { enableScripts: true, retainContextWhenHidden: true }
        );
        const repl = makePyretPane(panel, context, document, 'repl');
        repls.set(uri, repl);
        repl.pane.onDidDispose(() => { repls.delete(uri); });
      }
    } else {
      console.log("No active text editor found.");
    }
    console.log("Command handler args: ", args);
  };
}


export class PyretCPOWebProvider implements vscode.CustomTextEditorProvider {

  public static register(context: vscode.ExtensionContext): vscode.Disposable {
    const provider = new PyretCPOWebProvider(context);
    const providerRegistration = vscode.window.registerCustomEditorProvider(PyretCPOWebProvider.viewType, provider, {
      webviewOptions: {
        retainContextWhenHidden: true,
      }
    });
    return providerRegistration;
  }

  private static readonly viewType = 'pyret-parley.cpo';

  constructor(
    private readonly context: vscode.ExtensionContext
  ) { }

  /**
   * Called when our custom editor is opened.
   * 
   * 
   */
  public async resolveCustomTextEditor(
    document: vscode.TextDocument,
    webviewPanel: vscode.WebviewPanel,
    _token: vscode.CancellationToken
  ): Promise<void> {
    console.log("Pyret: resolving custom text editor at: ", document.uri);
    makePyretPane(webviewPanel, this.context, document, 'cpo');
  }
}

function getTheme(vscodeTheme: vscode.ColorThemeKind): string {
  switch (vscodeTheme) {
    case vscode.ColorThemeKind.Light:
      return 'default';
    case vscode.ColorThemeKind.HighContrastLight:
      return 'high-contrast-light';
    case vscode.ColorThemeKind.Dark:
      return 'monokai';
    case vscode.ColorThemeKind.HighContrast:
      return 'high-contrast-dark';
    default:
      return 'default';
  }
}

/**
 * Get the static html used for the editor webviews.
 */
export function getHtmlForWebview(context: vscode.ExtensionContext, webview: vscode.Webview, showDefinitions = true): string {
  const config = vscode.workspace.getConfiguration('pyret-parley');
  const theme = getTheme(vscode.window.activeColorTheme.kind);
  let urlFileMode = config.get('urlFileMode');
  const baseURI = webview.asWebviewUri(vscode.Uri.joinPath(context.extensionUri, 'dist', 'web', 'build', 'web'));
  let view = "";
  if (showDefinitions === false) {
    view = "hideDefinitions=true&headerStyle=hide";
  }
  else {
    view = "hideInteractions=true";
  }
  const templated = 
    render((code as string), {
      BASE_URL: baseURI.toString(),
      PYRET: webview.asWebviewUri(vscode.Uri.joinPath(baseURI, 'js', 'cpo-main.jarr.js')).toString(),
      HASH_OPTIONS: `#footerStyle=hide&${view}&theme=${theme}`,
      URL_FILE_MODE: urlFileMode,
      IMAGE_PROXY_BYPASS: "true"
    });
  console.log("Templated: ", templated);
  return templated;
}


type PyretPaneType = 'repl' | 'cpo';

type PyretPane = {
  pane: vscode.WebviewPanel;
  context: vscode.ExtensionContext;
  document: vscode.TextDocument;
  type: PyretPaneType;
  reset: () => void;
}

export function makePyretPane(
  pane : vscode.WebviewPanel,
  context: vscode.ExtensionContext,
  document: vscode.TextDocument,
  type: PyretPaneType
): PyretPane {
    const knownModules = {
      'fs': {
        'writeFile': async (p: string, buffer : Buffer) => {
          const pathUri = Utils.resolvePath(Utils.dirname(document.uri), p);
          await vscode.workspace.fs.writeFile(pathUri, buffer);
          return;
        },
        'readFile': async (p: string, opts : ReadFileOpts) => {
          const pathUri = Utils.resolvePath(Utils.dirname(document.uri), p);
          console.log("ReadFile: ", pathUri, p, document.uri);
          const contents = await vscode.workspace.fs.readFile(pathUri);
          if(opts && (opts === 'utf8' || opts.encoding === 'utf8')) {
            return Buffer.from(contents).toString('utf8');
          }
          else {
            return contents;
          }
        },
        'stat': async (p: string) => {
          const pathUri = vscode.Uri.joinPath(Utils.dirname(document.uri), p);
          const stat = await vscode.workspace.fs.stat(pathUri);
          return {
            mtime: stat.mtime,
            ctime: stat.ctime,
            size: stat.size,
            native: stat
          };
        },
        'createDir': async (p: string) => {
          const pathUri = Utils.resolvePath(Utils.dirname(document.uri), p);
          await vscode.workspace.fs.createDirectory(pathUri);
          return;
        }
      },
      'path': {
        'join': path.join,
        'resolve': (p : string) => {
          const docUri = Utils.dirname(document.uri);
          const answer = path.resolve(docUri.fsPath, p);
          return answer;
        },
        'basename': (p: string) => path.basename(p),
        'dirname': (p: string) => path.dirname(p),
        'extname': (p: string) => path.extname(p),
        'relative': (from: string, to: string) => path.relative(knownModules.path.resolve(from), knownModules.path.resolve(to)),
        'is-absolute': (p: string) => path.isAbsolute(p),
      },
      'process': {
        'cwd': () => process.cwd()
      }
    }

    // Setup initial content for the webview
    pane.webview.options = {
      enableScripts: true,
    };
    const showDefinitions = type === 'cpo';
    pane.webview.html = getHtmlForWebview(context, pane.webview, showDefinitions);


    /*
    State/event management for the bidirectional mapping between the
    TextDocument (VScode's abstraction) and the webview's CodeMirror instance.

    We maintain a queue of edits to apply to the TextDocument, and process them
    one after another – they are asynchronous so we need to avoid basic races of
    our own creation.

    We take a bit of a strong position on edits coming from the webview getting
    priority:

    - isProcessingEdits is set to true while we are applying edits. If any edits
      come in from VScode, we ignore them, counting ours as more important.
    - If we get out of sync, or our edits fail to apply, we override everything
      with a full replacement of the text that came from the webview with that
      edit.

    This means that if the user is editing in VScode at the same time as the
    webview is trying to make edits, the webview will win. Same for doing
    undo/redo events triggered through VScode's menu options that happen at the
    same time the user is typing in the CodeMirror view – the webview's version
    of things wins.
    */
    const editQueue : [vscode.WorkspaceEdit, string][] = [];
    let isProcessingEdits = false;

    const changeDocumentSubscription = vscode.workspace.onDidChangeTextDocument(e => {
      const hasChanges = e.contentChanges.length > 0;
      const isOurDocument = e.document.uri.toString() === document.uri.toString();
      if (hasChanges && isOurDocument && !isProcessingEdits) {
        updateWebview(e.contentChanges);
      }
    });

    // Make sure we get rid of the listener when our editor is closed.
    pane.onDidDispose(() => {
      changeDocumentSubscription.dispose();
    });

    function updateWebview(contentChanges?: readonly vscode.TextDocumentContentChangeEvent[]) {
      if(!contentChanges) {
        pane.webview.postMessage({
          protocol: "pyret",
          data: {
            type: 'setContents',
            text: document.getText(),
          }
        });
        return;
      }
      for(const change of contentChanges) {
        pane.webview.postMessage({
          protocol: "pyret",
          data: {
            type: 'change',
            change: {
              from: { line: change.range.start.line, ch: change.range.start.character },
              to: { line: change.range.end.line, ch: change.range.end.character },
              text: change.text.split('\n'),
              origin: null
            }
          }
        });
      }
    }

    function enqueueEdit(edit: vscode.WorkspaceEdit, source: string) {
      editQueue.push([edit, source]);
      processEditQueue();
    }
    async function processEditQueue() {
      function enqueueFullEdit(source : string) {
        const fullEdit = new vscode.WorkspaceEdit();
        fullEdit.replace(
          document.uri,
          new vscode.Range(0, 0, document.lineCount, 0),
          source);
        editQueue.push([fullEdit, source]);
      }
      if (editQueue.length === 0) { return; }
      else if (isProcessingEdits) { return; }
      else {
        const [edit, source] = editQueue.shift()!;
        try {
          isProcessingEdits = true;
          console.log("Processing edit from ", source);
          const ok = await vscode.workspace.applyEdit(edit);
          // If something went wrong with the edit, try again but just force the
          // whole document contents to match
          if(!ok) {
            console.error("applyEdit returned false, updating full contents", edit, source);
            enqueueFullEdit(source);
          }
        }
        catch (e) {
          console.error("Error applying edit: ", e);
          enqueueFullEdit(source);
        }
        finally {
          isProcessingEdits = false;
          processEditQueue();
        }
      }

    }

    type RPCResponse = { resultType: 'value', result: any, } | { resultType: 'exception', exception: any };
    function sendRpcResponse(data: { callbackId: string }, result: RPCResponse) {
      pane.webview.postMessage({
        protocol: 'pyret-rpc',
        data: {
          type: 'rpc-response',
          callbackId: data.callbackId,
          ...result
        }
      });
    }

    // Receive message from the webview.
    pane.webview.onDidReceiveMessage(async e => {
      console.log("Message: ", e);
      if (e.protocol === 'pyret-rpc') {
        /**
         * data: { module: string, method: string, args: string[], callbackId: string }
         * 
         * { type: 'rpc', module: 'fs', method: 'readFile', args: ['path/to/file'], callbackId: 'some-id' }
         */
        console.log("RPC:", e.data);
        const module = (knownModules as any)[e.data.module];
        if (!(module as any)[e.data.method]) {
          sendRpcResponse(e.data, { resultType: 'exception', exception: `Unknown method ${e.data.method}` });
        }
        else {
          try {
            const result = await (module as any)[e.data.method](...e.data.args);
            sendRpcResponse(e.data, { resultType: 'value', result });
          } catch (exn) {
            sendRpcResponse(e.data, { resultType: 'exception', exception: String(exn) });
          }
        }
        return;
      }
      if (e.protocol !== 'pyret') { console.warn("Non-pyret message: ", e); return; }
      let definitionsAtLastRun : boolean | string = false;
      if('repl' === type) {
        definitionsAtLastRun = document.getText();
      }
      let docText = document.getText();
      if(docText === "") {
        const config = vscode.workspace.getConfiguration('pyret-parley');
        let context = config.get('defaultContext');
        docText = `use context ${context}\n\n`;
        const edit = new vscode.WorkspaceEdit();
        edit.insert(document.uri, new vscode.Position(0, 0), docText);
        await vscode.workspace.applyEdit(edit);
        document.save();
      }
      const initialState = {
        definitionsAtLastRun,
        interactionsSinceLastRun: [],
        editorContents: docText,
        replContents: "",
      };
      switch (e.data.type) {
        case 'pyret-init': {
          console.log("Got init", e);
          pane.webview.postMessage({
            protocol: 'pyret',
            data: {
              type: 'reset',
              state: JSON.stringify(initialState)
            },
          });
          pane.webview.postMessage({
            type: 'gainControl'
          });
          break;
        }
        case 'change': {
          console.log("Got change", e);
          const edit = new vscode.WorkspaceEdit();
          const { from, to, text } = e.data.change;
          const range = new vscode.Range(from.line, from.ch, to.line, to.ch);
          const newText = text.join('\n');
          edit.replace(document.uri, range, newText);
          enqueueEdit(edit, e.state.editorContents);
          break;
        }
        default: console.log("Got a message: ", e);
      }
    });

    updateWebview();

    return {
      pane,
      context,
      document,
      type,
      reset: () => { pane.webview.postMessage({
          protocol: 'pyret',
          data: {
            type: 'reset',
            state: JSON.stringify({
              definitionsAtLastRun: document.getText(),
              interactionsSinceLastRun: [],
              editorContents: document.getText(),
              replContents: "",
            })
          },
        });
      }
    };
}
