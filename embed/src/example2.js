import { makeEmbed } from "../dist/pyret.js";
async function example2() {
  const iframeContainer = document.getElementById("example2");
  const embed = await makeEmbed('basic2', iframeContainer);

  const code = `use context starter2024\n\n`;

  const interactions = [
"circ = circle(25, 'solid', 'red')",
"rect = rectangle(200, 100, 'outline', 'black')"
]

  embed.sendReset({
    definitionsAtLastRun: code,
    interactionsSinceLastRun: interactions,
    editorContents: code,
    replContents: ""
  });


  const button = document.getElementById("example2-button");
  button.addEventListener('click', () => {
    embed.setInteractions("overlay(circ, rect)");
  });
}

window.addEventListener('load', example2);

let codeContainer = document.getElementById("example2-code");
codeContainer.innerText = String(example2);

