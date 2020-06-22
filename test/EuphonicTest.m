classdef EuphonicTest < EuphonicTestSuper

    properties
        euphonic_sf_args
    end

    % These parameters are related to performance, and shouldn't change the
    % result
    properties (MethodSetupParameter)
        use_c = {false, true, true};
        n_threads = {int32(1), int32(1), int32(2)};
        chunk = {5, missing, missing};
    end
    
    methods (TestMethodSetup, ParameterCombination='sequential')
        function set_euphonic_sf_args(testCase, use_c, n_threads, chunk)
            qpts = testCase.qpts;
            opts = testCase.opts;
            pars = testCase.pars;
            phonon_kwargs = {'phonon_kwargs', ...
                                {'asr', 'reciprocal', ...
                                    'use_c', use_c, ...
                                    'n_threads', n_threads}};
            opts = [opts phonon_kwargs];
            if ~ismissing(chunk)
                opts = [opts {'chunk', chunk}];
            end
            
            euphonic_sf_args = {qpts(:, 1), qpts(:, 2), qpts(:, 3), ...
                                pars, testCase.scattering_lengths, opts};
            testCase.euphonic_sf_args = euphonic_sf_args;
        end
    end

    methods(Test, ParameterCombination='sequential', TestTags={'integration'})
        function runIntegrationTests(testCase)
            [w, sf] = euphonic_sf(testCase.euphonic_sf_args{:});
            w_mat = cell2mat(w);
            sf_mat = cell2mat(sf);

            fname = get_expected_output_filename(testCase.material_name, ...
                                                 testCase.pars, testCase.opts);
            load(fname, 'expected_w', 'expected_sf');
            expected_w_mat = cell2mat(expected_w);
            expected_sf_mat = cell2mat(expected_sf);

            testCase.verifyTrue( ...
                all(ismembertol(w_mat, expected_w_mat, 1e-5), 'all'));
            % Ignore acoustic structure factors by setting to zero - their
            % values can be unstable at small frequencies
            sf_mat(:, 1:3) = 0;
            expected_sf_mat(:, 1:3) = 0;
            idx = find(strcmp('negative_e', testCase.opts));
            if length(idx) == 1 && testCase.opts{idx + 1} == true
                n = size(sf_mat, 2)/2;
                sf_mat(:, n+1:n+3) = 0;
                expected_sf_mat(:, n+1:n+3) = 0;
            end
            % Need to sum over degenerate modes to compare structure factors
            sf_summed = sum_degenerate_modes(w_mat, sf_mat);
            expected_sf_summed = sum_degenerate_modes(w_mat, expected_sf_mat);
            testCase.verifyTrue( ...
                all(ismembertol(sf_summed, expected_sf_summed, 1e-2), 'all'));
        end
    end
end