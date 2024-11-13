include chart
include image
import color as C
# include image-structs
include math

labels = [list: "cats", "dogs", "ants", "elephants"]
count = [list: 3, 7, 4, 9]

# zoo-series = from-list.dot-chart(labels, count)

just-red = [list: C.red]
rainbow-colors = [list: C.red, C.orange, C.yellow, C.green, C.blue, C.indigo, C.violet]
manual-colors =
  [list:
    C.color(51, 72, 252, 0.57), C.color(195, 180, 104, 0.87),
    C.color(115, 23, 159, 0.24), C.color(144, 12, 138, 0.13),
    C.color(31, 132, 224, 0.83), C.color(166, 16, 72, 0.59),
    C.color(58, 193, 241, 0.98)]
fewer-colors = [list: C.red, C.green, C.blue, C.orange, C.purple]
more-colors = [list: C.red, C.green, C.blue, C.orange, C.purple, C.yellow, C.indigo, C.violet]

fun render-image(series):
  # render-chart(series).get-image()
  render-chart(series)
end

# r-x-values = [list: 1, 2, 3, 4, 5, 6, 8, 9, 10, 24, 30]
# r-y-values = [list: 5, 3, 6, 4, 3, 3, 3, 2,  1,  1,  1]

r-x-values = [list: 1,1,1,1,1,
                    2,2,2,
                    3,3,3,3,3,3,
                    4,4,4,4,
                    5,5,5,
                    6,6,6,
                    8,8,8,
                    9,9,
                    10,
                    24,
                    30]

# r-zoo-series = from-list.num-dot-chart(r-x-values, r-y-values)
r-zoo-series = from-list.num-dot-chart(r-x-values)

r-zoo = render-image(r-zoo-series)

# Do r-zoo.display() to see resizable chart

fun t():
  r-zoo.display()
end
