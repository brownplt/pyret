import { makeEmbed } from "../dist/pyret.js";
async function example3() {
  const iframeContainer = document.getElementById("example3");
  const embed = await makeEmbed('basic3', iframeContainer);

  const code = `use context starter2024
fun rocket-height(n):
  ...
end
examples:
  rocket-height(5) is 25
end
`;

  const interactions = []

  function reset() {
    embed.sendReset({
      definitionsAtLastRun: false, // NB: set this to false to indicate the program has never run!
      interactionsSinceLastRun: interactions,
      editorContents: code,
      replContents: ""
    });
  }
  reset();

  const button = document.getElementById("example3-button");
  button.addEventListener('click', () => {
    reset();
  });
}

window.addEventListener('load', example3);

let codeContainer = document.getElementById("example3-code");
codeContainer.innerText = String(example3);

