function ind = IfInBox(loc, box)
    ind = (loc(1, :) > box(1)) & (loc(1, :) < box(2)) & (loc(2, :) > box(3)) & (loc(2, :) < box(4));
end