const example = `use context starter2024

# Objects can have methods

point-methods = {
  method dist(self, other):
    ysquared = num-expt(other.y - self.y, 2)
    xsquared = num-expt(other.x - self.x, 2)
    num-sqrt(ysquared + xsquared)
  end
}

fun make-point(x, y):
  point-methods.{ x: x, y: y }
end

check:
  p1 = make-point(1, 2)
  p2 = make-point(1, 5)
  p1.dist(p2) is 3
end

# Algebraic datatypes can also have methods

data Tree:
  | mt with: 
    method size(self): 0 end
  | node(v, l, r) with: 
    method size(self): 1 + self.l.size() + self.r.size() end
end

check:
  t = node(1, node(2, mt, mt), node(3, mt, node(4, mt, mt)))
  t.size() is 4
end`;

export const oop = {
    definitionsAtLastRun: example,
    interactionsSinceLastRun: [ ],
    editorContents: example,
    replContents: ""
}
