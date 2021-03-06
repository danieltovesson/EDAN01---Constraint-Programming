/** @group globals.packing
  Constrains rectangles \p i, given by their origins (\a x[\p i], \a y[\p i])
  and sizes (\a dx[\p i], \a dy[\p i]), to be non-overlapping. Zero-width
  rectangles can still not overlap with any other rectangle.
*/
predicate diffn(array[int] of var int: x,
                array[int] of var int: y,
                array[int] of var int: dx,
                array[int] of var int: dy) =
    assert(
        index_set(x) = index_set(y)  /\
        index_set(x) = index_set(dx) /\
        index_set(x) = index_set(dy),
        "diffn: index set mismatch",
    jacop_diff2_strict(x, y, dx, dy)
    % forall(i,j in index_set(x) where i < j)(
    %     x[i] + dx[i] <= x[j] \/ y[i] + dy[i] <= y[j] \/
    %     x[j] + dx[j] <= x[i] \/ y[j] + dy[j] <= y[i]
    % )
    );

%-----------------------------------------------------------------------------%

predicate jacop_diff2_strict(array[int] of var int: x, array[int] of var int: y,
	        	     array[int] of var int: lx, array[int] of var int: ly);

% predicate jacop_diff2_strict_reif(array[int] of var int: x, array[int] of var int: y,
%  	        	     array[int] of var int: lx, array[int] of var int: ly, var bool: b) = 
%     abort("Reified diffn/1 is not supported.");
