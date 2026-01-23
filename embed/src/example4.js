import { makeEmbed } from "../dist/pyret.js";
async function example4() {
  const iframeContainer = document.getElementById("example4");
  const embed = await makeEmbed('basic4', iframeContainer);
  embed.sendReset("https://code.pyret.org/editor#share=1rj_zKiheibxod8IihAFeMpP91XjLROum");
}

window.addEventListener('load', example4);

let codeContainer = document.getElementById("example4-code");
codeContainer.innerText = String(example4);
