classdef EuphonicSfTestBrille < EuphonicSfTestBase
    methods(Test, TestTags={'integration', 'brille'})
        function runIntegrationTestsWithBrille(testCase)
            qpts = [ 0.0,  0.0,  0.0;
                     0.1,  0.2,  0.3;
                     0.4,  0.5,  0.0;
                     0.6,  0.0,  0.7;
                     0.0,  0.8,  0.9;
                    -0.5,  0.0,  0.0;
                     0.0, -0.5,  0.0;
                     0.0,  0.0, -0.5];
            material_name = 'quartz';
            fc = euphonic.ForceConstants.from_castep(...
                get_abspath('quartz.castep_bin', 'input'));

            bri = euphonic.BrilleInterpolator.from_force_constants( ...
                fc, 'grid_npts', 1000, 'interpolation_kwargs', struct('asr', 'reciprocal'));

            opts = {'temperature', 300};
            coherentsqw = euphonic.CoherentCrystal(bri, 'threads', 4, 'useparallel', true, opts{:});
            [w, sf] = coherentsqw.horace_disp(qpts(:, 1), qpts(:, 2), qpts(:, 3), {});
            w_mat = transpose(cell2mat(w'));
            sf_mat = transpose(cell2mat(sf'));
            [expected_w_mat, expected_sf_mat] = testCase.get_expected_w_sf(...
                material_name, opts);
            % Don't test last q-point - unstable
            expected_w_mat = expected_w_mat(1:8,:);
            expected_sf_mat = expected_sf_mat(1:8,:);

            w_mat = testCase.zero_acoustic_vals(w_mat, expected_w_mat);
            expected_w_mat = testCase.zero_acoustic_vals(expected_w_mat, expected_w_mat);
            mean_frequency_residual = mean(abs(w_mat - expected_w_mat), 'all');
            testCase.verifyLessThan(mean_frequency_residual, 0.15);

            sf_mat = testCase.zero_acoustic_vals(sf_mat, expected_w_mat);
            expected_sf_mat = testCase.zero_acoustic_vals(expected_sf_mat, expected_w_mat);
            % Need to sum over degenerate modes to compare structure factors
            sf_summed = testCase.sum_degenerate_modes(expected_w_mat, sf_mat);
            expected_sf_summed = testCase.sum_degenerate_modes(expected_w_mat, expected_sf_mat);
            mean_sf_residual = mean(abs(sf_summed - expected_sf_summed), 'all');
            testCase.verifyLessThan(mean_sf_residual, 0.004);
        end
    end
end
