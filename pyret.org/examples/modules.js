const example = `use context starter2024

import url("https://raw.githubusercontent.com/brownplt/pyret.org/786f1539e41d47694ef69312a93804672da0bbf1/examples/code/home-page-modules.arr") as TTT

TTT.draw-board(TTT.board-blank)

X = TTT.X
O = TTT.O
Blank = TTT.Blank

board-xox =
  TTT.board(
    [array:
      [array: X, Blank, Blank],
      [array: Blank, O, Blank],
      [array: Blank, Blank, X]])

TTT.draw-board(board-xox)

# The following is *not* \`provide\`d, so this will produce an error:
# TTT.pos2icon
`;

export const modules = {
  definitionsAtLastRun: example,
  editorContents: example,
  replContents: ""
};
