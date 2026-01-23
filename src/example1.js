
import { makeEmbedConfig } from "../dist/pyret.js";
async function example1() {
  const iframeContainer = document.getElementById("example1");
  makeEmbedConfig({
    container: iframeContainer,
    state: {
      editorContents: "use context starter2024\n\n'Hello!'",
      replContents: "",
      definitionsAtLastRun: "use context starter2024\n\n'Hello!'",
      interactionsSinceLastRun: []
    },
  });
}

window.addEventListener('load', example1);

let codeContainer = document.getElementById("example1-code");
codeContainer.innerText = String(example1);

