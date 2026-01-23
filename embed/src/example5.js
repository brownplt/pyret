import { makeEmbed } from "../dist/pyret.js";
async function example5() {
  const iframeContainer = document.getElementById("example5");
  const embed = await makeEmbed('basic5', iframeContainer);

  const code = `use context starter2024\n\n
# Fill in the definition of x to contain the string "embed"`;

  const interactions = [ ]

  embed.sendReset({
    definitionsAtLastRun: false,
    interactionsSinceLastRun: interactions,
    editorContents: code,
    replContents: ""
  });

  const button = document.getElementById("example5-button");
  const resultDiv = document.getElementById("example5-result");
  button.addEventListener('click', async () => {
    embed.setInteractions("x");
    const result = await embed.runInteractionResult();
    console.log(result);
    if(result.indexOf("embed") !== -1) {
      resultDiv.innerText = `Success!  (Result was ${result})`;
    }
    else {
      resultDiv.innerText = `Failure!  (Result was ${result})`;
    }
  });
}
  
window.addEventListener('load', example5);
  
let codeContainer = document.getElementById("example5-code");
codeContainer.innerText = String(example5);
  
  