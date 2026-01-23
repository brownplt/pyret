const example = `use context starter2024

data NumTree:
    | leaf
    | node(value, left, right)
end

fun in-tree(t, val-to-find):
    cases(NumTree) t:
        | leaf => false
        | node(value, left, right) =>
          if val-to-find == value:
            true
          else:
            in-tree(left, val-to-find) or in-tree(right, val-to-find)
          end
    end
end
check:
    in-tree(leaf, 7) is false
    in-tree(node(6, leaf, leaf), 7) is false
    in-tree(node(7, leaf, leaf), 7) is true

    sample-tree = node(6,
        node(9, leaf, leaf),
        node(13,
            leaf,
            node(3, leaf, leaf)))
    
    in-tree(sample-tree, 7) is false
    for each(n from [list: 6, 9, 13, 3]):
        in-tree(sample-tree, n) is true
    end
end
`;

export const data = {
    definitionsAtLastRun: example,
    interactionsSinceLastRun: [ ],
    editorContents: example,
    replContents: ""
}
