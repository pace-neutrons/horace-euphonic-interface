function summed_sf = sum_degenerate_modes(w, sf)
    tol = 0.1;
    [rows, cols] = size(w);
    diff = zeros(cols-1, 1);
    summed_sf = zeros(size(sf));

    for i=1:rows
        for j=1:cols-1
            diff(j) = w(i, j+1) - w(i, j);

        end
        sum_at = find(diff > tol);
        x = zeros(cols, 1);
        x(sum_at + 1) = 1;
        degenerate_modes = cumsum(x);
        summed = accumarray(degenerate_modes + 1, sf(i,:));
        summed_sf(i,1:length(summed)) = summed;
    end

end

