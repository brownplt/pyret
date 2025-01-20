import * as vscode from 'vscode';
import { PyretCPOWebProvider } from './pyretCPOWebEditor';

export function activate(context: vscode.ExtensionContext) {
	// Register our custom editor providers
	context.subscriptions.push(PyretCPOWebProvider.register(context));
}