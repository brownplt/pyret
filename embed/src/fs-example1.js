import { makeEmbedConfig } from "../dist/pyret.js";
import { rpc } from "../dist/default-rpcs.js";

async function fsExample1() {
  const iframeContainer = document.getElementById("fs-example1");
  makeEmbedConfig({
    container: iframeContainer,
    rpc: rpc,
    src: "../dist/build/web/editor.embed.html",
    state: {
      editorContents: `use context starter2024

import filesystem as FS
FS.write-file-string('hello.txt', 'Hello, world!')
FS.read-file-string('hello.txt')`,
      replContents: "",
      definitionsAtLastRun: false,
      interactionsSinceLastRun: []
    },
  });
}

window.addEventListener('load', fsExample1);

let codeContainer = document.getElementById("fs-example1-code");
codeContainer.innerText = String(fsExample1);

