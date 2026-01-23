use context starter2024

provide:
  data TTTBoard,
  data TTTPos,
  draw-board,
  board-blank
end

data TTTPos:
  | X
  | O
  | Blank
end

fun pos2icon(c :: TTTPos) -> Image:
   size = 30
   bound = num-round(size * 1.5)
   overlay(
    center-pinhole(
      cases (TTTPos) c:
        | X => text("X", 30, "red")
        | O => text("O", 30, "blue")
        | Blank => text("-", 30, "black")
      end),
    square(bound, "solid", "white"))
end

fun has-3<T>(a :: Array<T>) -> Boolean:
  a.length() == 3
end

data TTTBoard:
  | board(cells :: Array<Array<TTTPos>%(has-3)>%(has-3))
end

fun image-col(l :: List<String>) -> Image:
  for fold(base from l.first, i from l.rest):
    above(base, i)
  end
end

fun image-row(l :: List<Image>) -> Image:
  for fold(base from l.first, i from l.rest):
    beside(base, i)
  end
end

fun draw-board<T>(b :: TTTBoard) -> Image:
  image-col(
    for map(col from range(0, 3)):
      image-row(
        for map(row from range(0, 3)):
          pos2icon(b.cells.get-now(col).get-now(row))
        end)
    end)
end

board-blank :: TTTBoard =
  board(
    [array: 
      [array: Blank, Blank, Blank],
      [array: Blank, Blank, Blank],
      [array: Blank, Blank, Blank]])

board-1 :: TTTBoard =
  board(
    [array: 
      [array: X, Blank, Blank],
      [array: Blank, O, Blank],
      [array: Blank, Blank, X]])

board-2 :: TTTBoard =
  board(
    [array: 
      [array: X, X, Blank],
      [array: Blank, O, O],
      [array: X, Blank, X]])

draw-board(board-blank)
draw-board(board-1)
draw-board(board-2)