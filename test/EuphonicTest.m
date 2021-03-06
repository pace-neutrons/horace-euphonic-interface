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
            opts = testCase.opts;
            pars = testCase.pars;
            phonon_kwargs = {'asr', 'reciprocal', ...
                             'use_c', use_c, ...
                             'n_threads', n_threads};
            opts = [opts phonon_kwargs];
            if ~ismissing(chunk)
                opts = [opts {'chunk', chunk}];
            end
            opts = [opts {'scattering_lengths', testCase.scattering_lengths}];
            opts = [opts {'temperature', pars(1)}];
            
            testCase.euphonic_sf_args = opts;
        end
    end

    methods(Test, ParameterCombination='sequential', TestTags={'integration'})
        function runIntegrationTests(testCase)
            coherentsqw = euphonic.CoherentCrystal(testCase.force_constants, ...
                                                   testCase.euphonic_sf_args{:});
            qpts = testCase.qpts;
            [w, sf] = coherentsqw.horace_disp(qpts(:, 1), qpts(:, 2), qpts(:, 3), ...
                                              testCase.pars(2));
            w_mat = transpose(cell2mat(w'));
            sf_mat = transpose(cell2mat(sf'));

            fname = get_expected_output_filename(testCase.material_name, ...
                                                 testCase.pars, testCase.opts);
            load(fname, 'expected_w', 'expected_sf');
            expected_w_mat = cell2mat(expected_w);
            expected_sf_mat = cell2mat(expected_sf);

            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.AbsoluteTolerance
            import matlab.unittest.constraints.RelativeTolerance
            bounds = AbsoluteTolerance(5e-4) | RelativeTolerance(0.01);
            testCase.verifyThat(w_mat, ...
                IsEqualTo(expected_w_mat, 'within', bounds));
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
            bounds = AbsoluteTolerance(0.01) | RelativeTolerance(0.01);
            testCase.verifyThat(sf_summed, ...
                IsEqualTo(expected_sf_summed, 'within', bounds));
        end
    end
end
