classdef EuphonicSfTest < EuphonicGenerateSfParams

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
            phonon_kwargs = {'asr', 'reciprocal', ...
                             'use_c', use_c, ...
                             'n_threads', n_threads};
            opts = [opts phonon_kwargs];
            if ~ismissing(chunk)
                opts = [opts {'chunk', chunk}];
            end
            opts = [opts {'scattering_lengths', testCase.scattering_lengths}];
            
            testCase.euphonic_sf_args = opts;
        end
    end
    methods(Test, ParameterCombination='sequential', TestTags={'integration', 'phonopy_reader'})
        function runIntegrationTestsWithPhonopyData(testCase)
            material_name = 'nacl';
            force_constants = euphonic.ForceConstants.from_phonopy(...
                'path', get_abspath('NaCl', 'input'));

            coherentsqw = euphonic.CoherentCrystal(force_constants, ...
                                                   testCase.euphonic_sf_args{:});
            qpts = testCase.qpts;
            [w, sf] = coherentsqw.horace_disp(qpts(:, 1), qpts(:, 2), qpts(:, 3), {});
            w_mat = transpose(cell2mat(w'));
            sf_mat = transpose(cell2mat(sf'));

            [expected_w_mat, expected_sf_mat] = testCase.get_expected_w_sf(...
                material_name, testCase.opts);

            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.AbsoluteTolerance
            import matlab.unittest.constraints.RelativeTolerance
            bounds = AbsoluteTolerance(6e-4) | RelativeTolerance(0.01);
            testCase.verifyThat(w_mat, ...
                IsEqualTo(expected_w_mat, 'within', bounds));

            % Ignore acoustic structure factors by setting to zero - their
            % values can be unstable at small frequencies
            sf_mat = testCase.zero_acoustic_sf(sf_mat, testCase.opts);
            expected_sf_mat = testCase.zero_acoustic_sf(expected_sf_mat, testCase.opts);
            % Need to sum over degenerate modes to compare structure factors
            sf_summed = testCase.sum_degenerate_modes(w_mat, sf_mat);
            expected_sf_summed = testCase.sum_degenerate_modes(w_mat, expected_sf_mat);
            bounds = AbsoluteTolerance(0.01) | RelativeTolerance(0.01);
            testCase.verifyThat(sf_summed, ...
                IsEqualTo(expected_sf_summed, 'within', bounds));
        end
    end
    methods(Test, ParameterCombination='sequential', TestTags={'integration'})
        function runIntegrationTestsWithCastepData(testCase)
            material_name = 'quartz';
            force_constants = euphonic.ForceConstants.from_castep(...
                get_abspath('quartz.castep_bin', 'input'));

            coherentsqw = euphonic.CoherentCrystal(force_constants, ...
                                                   testCase.euphonic_sf_args{:});
            qpts = testCase.qpts;
            [w, sf] = coherentsqw.horace_disp(qpts(:, 1), qpts(:, 2), qpts(:, 3), {});
            w_mat = transpose(cell2mat(w'));
            sf_mat = transpose(cell2mat(sf'));

            [expected_w_mat, expected_sf_mat] = testCase.get_expected_w_sf(...
                material_name, testCase.opts);

            import matlab.unittest.constraints.IsEqualTo
            import matlab.unittest.constraints.AbsoluteTolerance
            import matlab.unittest.constraints.RelativeTolerance
            bounds = AbsoluteTolerance(6e-4) | RelativeTolerance(0.01);
            testCase.verifyThat(w_mat, ...
                IsEqualTo(expected_w_mat, 'within', bounds));

            % Ignore acoustic structure factors by setting to zero - their
            % values can be unstable at small frequencies
            sf_mat = testCase.zero_acoustic_sf(sf_mat, testCase.opts);
            expected_sf_mat = testCase.zero_acoustic_sf(expected_sf_mat, testCase.opts);
            % Need to sum over degenerate modes to compare structure factors
            sf_summed = testCase.sum_degenerate_modes(w_mat, sf_mat);
            expected_sf_summed = testCase.sum_degenerate_modes(w_mat, expected_sf_mat);
            bounds = AbsoluteTolerance(0.01) | RelativeTolerance(0.01);
            testCase.verifyThat(sf_summed, ...
                IsEqualTo(expected_sf_summed, 'within', bounds));
        end
    end
end
