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
        }
      },
      'path': {
        'join': path.join,
        'resolve': (p : string) => {
          const docUri = Utils.dirname(document.uri);
          const answer = path.resolve(docUri.fsPath, p);
          console.log("Path.resolve: ", docUri.fsPath, p, answer);
          return answer;
        }
      },
      'process': {
        'cwd': () => {
          console.log("cwd: ", process.cwd());
          process.cwd();
        }
      }
    }

    // Setup initial content for the webview
    webviewPanel.webview.options = {
      enableScripts: true,
    };
    webviewPanel.webview.html = this.getHtmlForWebview(webviewPanel.webview);

    function updateWebview() {
      webviewPanel.webview.postMessage({
        type: 'setContents',
        text: document.getText(),
      });
    }

    // Hook up event handlers so that we can synchronize the webview with the text document.
    //
    // The text document acts as our model, so we have to sync change in the document to our
    // editor and sync changes in the editor back to the document.
    // 
    // Remember that a single text document can also be shared between multiple custom
    // editors (this happens for example when you split a custom editor)

    const changeDocumentSubscription = vscode.workspace.onDidChangeTextDocument(e => {
      if (e.document.uri.toString() === document.uri.toString()) {
        updateWebview();
      }
    });

    // Make sure we get rid of the listener when our editor is closed.
    webviewPanel.onDidDispose(() => {
      changeDocumentSubscription.dispose();
    });

    type RPCResponse = { resultType: 'value', result: any, } | { resultType: 'exception', exception: any };
    function sendRpcResponse(data: { callbackId: string }, result: RPCResponse) {
      webviewPanel.webview.postMessage({
        protocol: 'pyret-rpc',
        data: {
          type: 'rpc-response',
          callbackId: data.callbackId,
          ...result
        }
      });
    }

    // Receive message from the webview.
    webviewPanel.webview.onDidReceiveMessage(async e => {
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
          sendRpcResponse(e.data, { resultType: 'exception', exception: "Unknown method" });
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
      const initialState = {
        definitionsAtLastRun: false,
        interactionsSinceLastRun: [],
        editorContents: document.getText(),
        replContents: "",
      };
      switch (e.data.type) {
        case 'pyret-init': {
          console.log("Got init", e);
          webviewPanel.webview.postMessage({
            protocol: 'pyret',
            data: {
              type: 'reset',
              state: JSON.stringify(initialState)
            },
          });
          webviewPanel.webview.postMessage({
            type: 'gainControl'
          });
          break;
        }
        case 'change': {
          console.log("Got change", e);
          const edit = new vscode.WorkspaceEdit();

          // Just replace the entire document every time for this example extension.
          // A more complete extension should compute minimal edits instead.
          // NOTE(joe): we have these on the change events from CodeMirror
          edit.replace(
            document.uri,
            new vscode.Range(0, 0, document.lineCount, 0),
            e.state.editorContents)
          vscode.workspace.applyEdit(edit);
          document.save();
          break;
        }
        default: console.log("Got a message: ", e);
      }
    });

    updateWebview();
  }

  /**
   * Get the static html used for the editor webviews.
   */
  private getHtmlForWebview(webview: vscode.Webview): string {
    const config = vscode.workspace.getConfiguration(
      'pyret-parley'
    );
    console.log("Config: ", config);
    let urlFileMode = config.get('urlFileMode');
    const baseURI = webview.asWebviewUri(vscode.Uri.joinPath(this.context.extensionUri, 'dist', 'web', 'build', 'web'));
    console.log("baseURI: ", baseURI);
    const templated = 
      render((code as string), {
        BASE_URL: baseURI.toString(),
        PYRET: webview.asWebviewUri(vscode.Uri.joinPath(baseURI, 'js', 'cpo-main.jarr.js')).toString(),
        HASH_OPTIONS: "#footerStyle=hide&hideInteractions=true",
        URL_FILE_MODE: urlFileMode,
        IMAGE_PROXY_BYPASS: "true"
      });
    console.log("Templated: ", templated);
    return templated;
  }
}