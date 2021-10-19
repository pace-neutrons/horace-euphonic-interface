classdef EuphonicTestScalePars < matlab.unittest.TestCase

    properties (TestParameter)
        % intensity_scale, frequency_scale, horace_disp_args
        scale_pars = {{2e2, 0.9, {[2e2, 0.9]}}, ...
                      {1.5e4, 0.5, {1.5e4, 0.5}}, ...
                      {50, 0.7, {50, 'frequency_scale', 0.7}}, ...
                      {3, 1.2, {'frequency_scale', 1.2, 'intensity_scale', 3}}, ...
                      {1., 1.2, {'frequency_scale', 1.2}}, ...
                      {3., 1., {'intensity_scale', 3}, ...
                      {50., 1., {50}}}};
    end

    methods(Test, ParameterCombination='sequential', TestTags={'integration'})
        function testScaleParameters(testCase, scale_pars)
            [iscale, fscale, horace_disp_args] = scale_pars{:};
            qpts = [ 0.0,  0.0,  0.0;
                     0.1,  0.2,  0.3;
                     0.4,  0.5,  0.0;
                     0.6,  0.0,  0.7;
                     0.0,  0.8,  0.9;
                    -0.5,  0.0,  0.0;
                     0.0, -0.5,  0.0;
                     0.0,  0.0, -0.5;
                     1.0, -1.0, -1.0];
            fc = euphonic.ForceConstants.from_castep(get_abspath('quartz.castep_bin', 'input'));
            coh_kwargs = {'temperature', 300, ...
                          'debye_waller_grid', [6,6,6], ...
                          'conversion_mat', (1/2)*[-1, 1, 1; 1, -1, 1; 1, 1, -1], ...
                          'asr', 'reciprocal'};
                      
            coherentsqw = euphonic.CoherentCrystal(fc, coh_kwargs{:});
            fname = get_expected_output_filename('quartz', coh_kwargs);

            [w, sf] = coherentsqw.horace_disp(qpts(:, 1), qpts(:, 2), qpts(:, 3), horace_disp_args{:});
            w_mat = transpose(cell2mat(w'));
            sf_mat = transpose(cell2mat(sf'));

            fname = get_expected_output_filename('quartz', coh_kwargs);
            load(fname, 'expected_w', 'expected_sf');
            expected_w_mat = cell2mat(expected_w);
            expected_sf_mat = cell2mat(expected_sf);

            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.AbsoluteTolerance
            import matlab.unittest.constraints.RelativeTolerance
            bounds = AbsoluteTolerance(fscale*6e-4) | RelativeTolerance(0.01);
            testCase.verifyThat(w_mat, ...
                IsEqualTo(fscale*expected_w_mat, 'within', bounds));
            % Ignore acoustic structure factors by setting to zero - their
            % values can be unstable at small frequencies
            sf_mat(:, 1:3) = 0;
            expected_sf_mat(:, 1:3) = 0;
            idx = find(strcmp('negative_e', coh_kwargs));
            if length(idx) == 1 && testCase.opts{idx + 1} == true
                n = size(sf_mat, 2)/2;
                sf_mat(:, n+1:n+3) = 0;
                expected_sf_mat(:, n+1:n+3) = 0;
            end
            % Need to sum over degenerate modes to compare structure factors
            sf_summed = sum_degenerate_modes(w_mat, sf_mat);
            expected_sf_summed = sum_degenerate_modes(w_mat, expected_sf_mat);
            bounds = AbsoluteTolerance(iscale*0.01) | RelativeTolerance(0.01);
            testCase.verifyThat(sf_summed, ...
                IsEqualTo(iscale*expected_sf_summed, 'within', bounds));
        end
    end
end
