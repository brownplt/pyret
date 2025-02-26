Borrows heavily from https://github.com/microsoft/vscode-extension-samples/tree/main/custom-editor-sample

To run, first you must symlink `build` to a the `build/` directory of
`code.pyret.org`. You can get one by cloning `code.pyret.org` elsewhere and
symlinking to it.

Then:

```
npm i
npm run compile
npx vscode-test-web --browserType=chromium --extensionDevelopmentPath . ./sampleFiles/
```

