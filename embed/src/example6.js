import { makeEmbed } from "../dist/pyret.js";
async function example6() {
  const iframeContainer = document.getElementById("example6");
  const embed = await makeEmbed('basic6', iframeContainer);

  const code = `use context starter2024\n\n
# Fill in the definition of x to contain the string "embed"`;

  const interactions = [ ]

  embed.sendReset({
    definitionsAtLastRun: false,
    interactionsSinceLastRun: interactions,
    editorContents: code,
    replContents: ""
  });

  const button = document.getElementById("example6-button");
  const resultDiv = document.getElementById("example6-result");
  button.addEventListener('click', async () => {
    embed.runDefinitions();
    embed.setInteractions("x\n1000\ncheck: 200 is x end\n");
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

window.addEventListener('load', example6);

let codeContainer = document.getElementById("example6-code");
codeContainer.innerText = String(example6);
