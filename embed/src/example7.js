import { makeEmbed } from "../dist/pyret.js";
async function example7() {
  const iframeContainer = document.getElementById("example7");
  const embed = await makeEmbed('basic7', iframeContainer);

  const code = `use context starter2024\n\n`;

  const interactions = [ "10", "circle(50, 'solid', 'red')" ]

  embed.sendReset({
    definitionsAtLastRun: code,
    interactionsSinceLastRun: interactions,
    editorContents: code,
    replContents: ""
  });

  const button = document.getElementById("example7-button");
  const resultDiv = document.getElementById("example7-result");
  button.addEventListener('click', async () => {
    embed.clearInteractions();
  });
}

window.addEventListener('load', example7);

let codeContainer = document.getElementById("example7-code");
codeContainer.innerText = String(example7);
