classdef EuphonicGenerateTestData < EuphonicTestSuper
    methods(Test)
        function generateTestData(testCase)
            generate_test_data = false;
            testCase.assumeEqual(generate_test_data, true);

            qpts = testCase.qpts;
            opts = testCase.opts;
            pars = testCase.pars;
            phonon_kwargs = {'phonon_kwargs', {'asr', 'reciprocal'}};
            opts = [opts phonon_kwargs];
            [expected_w, expected_sf] = euphonic_sf( ...
               qpts(:,1), qpts(:,2), qpts(:,3), ...
               testCase.pars, testCase.scattering_lengths, opts);
            fname = get_expected_output_filename(testCase.material_name, ...
                                                 pars, opts);
            save(fname, 'expected_w', 'expected_sf');
        end
    end
end