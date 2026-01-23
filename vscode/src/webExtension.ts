import * as vscode from 'vscode';
import { PyretCPOWebProvider, makeCommandHandler } from './pyretCPOWebEditor';

export function activate(context: vscode.ExtensionContext) {
	// Register our custom editor providers
	context.subscriptions.push(PyretCPOWebProvider.register(context));
    context.subscriptions.push(vscode.commands.registerCommand("pyret-parley.run-file", makeCommandHandler(context)));
}