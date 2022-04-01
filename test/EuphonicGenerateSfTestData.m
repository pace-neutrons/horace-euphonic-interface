classdef EuphonicGenerateSfTestData < EuphonicGenerateSfParams
    methods(Test, TestTags={'generate'})
        function generateTestData(testCase)
            generate_test_data = false;
            if generate_test_data
                qpts = testCase.qpts;
                opts = testCase.opts;
                pars = testCase.pars;
                phonon_kwargs = {'asr', 'reciprocal'};
                opts = [opts phonon_kwargs];
                opts = [opts {'scattering_lengths', testCase.scattering_lengths}];
                opts = [opts {'temperature', pars(1)}];
                coherentsqw = euphonic.CoherentCrystal(testCase.force_constants, opts{:});
                [expected_w, expected_sf] = coherentsqw.horace_disp( ...
                   qpts(:,1), qpts(:,2), qpts(:,3), testCase.pars(2));
                expected_w = cellfun(@transpose, expected_w, 'UniformOutput', false);
                expected_sf = cellfun(@transpose, expected_sf, 'UniformOutput', false);
                fname = get_expected_output_filename(testCase.material_name, ...
                                                     pars, opts);
                save(fname, 'expected_w', 'expected_sf');
            end
        end
    end
end
