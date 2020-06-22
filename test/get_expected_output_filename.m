function fname = get_expected_output_filename(material_name, pars, opts)
    fname = material_name;
    fname = [fname '_T' string(pars(1))];

    idx = find(strcmp('dw_grid', opts));
    if length(idx) == 1
        grid = opts(idx + 1);
        fname = [fname '_dw' string(grid{:})];
    end

    idx = find(strcmp('bose', opts));
    if length(idx) == 1
        fname = [fname '_bose' string(opts(idx + 1))];
    end

    idx = find(strcmp('negative_e', opts));
    if length(idx) == 1
        fname = [fname '_negative_e' string(opts(idx + 1))];
    end

    idx = find(strcmp('conversion_mat', opts));
    if length(idx) == 1
        fname = [fname '_conv_mat_det' string(det(cell2mat(opts(idx + 1))))];
    end

    idx = find(strcmp('lim', opts));
    if length(idx) == 1
        fname = [fname '_lim' string(opts(idx + 1))];
    end

    fname = strrep(fname, '.', 'p');
    fname = strrep(fname, '-', 'm');

    fname = char(strjoin(fname, ''));
    fname = get_abspath(fname, 'expected_output');
end

