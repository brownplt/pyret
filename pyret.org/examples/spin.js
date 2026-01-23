
const code = `
use context starter2024

flag = image-url("https://raw.githubusercontent.com/brownplt/pyret-lang/refs/heads/horizon/img/pyret-sticker-caps.png")
blackout = rectangle(550, 425, "solid", "black")
blank-flag = place-image(blackout, 450, 285, flag)
bonnie = scale(0.75, image-url("https://raw.githubusercontent.com/brownplt/pyret-lang/refs/heads/horizon/img/pyret-logo.png"))
fun draw-bonnie(angle :: Number) -> Image:
  scale(0.5, place-image(rotate(angle, bonnie), 450, 285, blank-flag))
end
spinner = reactor:
  init: 0,
  on-tick: {(angle): angle + 5},
  to-draw: draw-bonnie
end

spinner.interact()
`;

const interactions = ["flag", "blackout", "blank-flag"];

export const spin = {
    definitionsAtLastRun: code,
    interactionsSinceLastRun: interactions,
    editorContents: code,
    replContents: ""
}
