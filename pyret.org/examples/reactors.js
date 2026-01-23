export const example = `use context starter2024
type State = {h :: Number, m :: Number}
# h is [0, 11], m is [0, 59]

init-time :: State = {h: 0, m: 0}

fun next(s :: State) -> State:
  new-time = s.{m: s.m + 1}
  if new-time.m < 60:
    new-time
  else:
    new-time.{
      m: 0,
      h: num-modulo(new-time.h + 1, 12)
    }
  end
end

SIZE = 100
SCALE = 0.9
BG = overlay(circle(SIZE, "outline", "black"),
  square(2 * SIZE, "solid", "white"))

type Coords = {x :: Number, y :: Number}
# x is [0, SIZE], y is [0, SIZE]

fun compute-coords(s) -> Coords:
  fun deg2rad(d :: Number): d * 0.01745329 end
  m-angle = deg2rad((0 - (6 * s.m)) + 90)
  m-x = (SIZE * SCALE * num-cos(m-angle))
  m-y = (SIZE * SCALE * num-sin(m-angle))
  {x: num-round(m-x), y: num-round(m-y)}
end

fun watch-hand(size :: Number, color :: String):
  hand = isosceles-triangle(size, 5, "solid", color)
  width = image-height(hand)
  height = image-height(hand)
  move-pinhole(0, height / 2, center-pinhole(hand))
end

fun draw(s :: State) -> Image:
  p = compute-coords(s)
  overlay(rotate((-6 * s.m), watch-hand(SIZE, "red")),
    overlay(rotate((-12 * (s.h + (s.m / 60))), 
        watch-hand(SIZE * 0.75, "blue")),
      BG))
end

r = reactor:
  init: init-time,
  on-tick: next,
  to-draw: draw
end

r.interact()
`;

export const reactors = {
    definitionsAtLastRun: false,
    interactionsSinceLastRun: [],
    editorContents: example,
    replContents: "Click Run!"
}
