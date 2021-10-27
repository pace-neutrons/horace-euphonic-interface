classdef EuphonicTestSuper < matlab.mock.TestCase

    properties
        qpts
        pars
        scattering_lengths
        opts
        material_name
        force_constants
    end

    properties (ClassSetupParameter)
        temp = {300};
        materials = { ...
           {'quartz', @euphonic.ForceConstants.from_castep, {get_abspath('quartz.castep_bin', 'input')}}, ...
           {'nacl',  @euphonic.ForceConstants.from_phonopy, {'path', get_abspath('NaCl', 'input')}}, ...
        }
        dw_grid = {missing, [6,6,6]};
        bose = {missing, false};
        negative_e = {missing, true};
        conversion_mat =  {missing, (1/2)*[-1, 1, 1; 1, -1, 1; 1, 1, -1]};
        lim = {missing, 1e2};
    end

    methods (TestClassSetup)
        function setQpts(testCase, temp, materials, dw_grid, bose, ...
                         negative_e, conversion_mat, lim)
            qpts = [ 0.0,  0.0,  0.0;
                     0.1,  0.2,  0.3;
                     0.4,  0.5,  0.0;
                     0.6,  0.0,  0.7;
                     0.0,  0.8,  0.9;
                    -0.5,  0.0,  0.0;
                     0.0, -0.5,  0.0;
                     0.0,  0.0, -0.5;
                     1.0, -1.0, -1.0];
            scattering_lengths = struct('La', 8.24, 'Zr', 7.16, 'O', 5.803, ...
                                        'Si', 4.1491, 'Na', 3.63, 'Cl', 9.577);

            opts = {};
            % Only add values to opts if they aren't missing
            opts_keys = {'debye_waller_grid', 'bose', 'negative_e', ...
                         'conversion_mat', 'lim', 'temperature'};
            opts_values = {dw_grid, bose, negative_e, conversion_mat, lim, temp};
            for i=1:length(opts_keys)
                if ~ismissing(opts_values{i})
                    opts = [opts {opts_keys{i}, opts_values{i}}];
                end
            end

            testCase.qpts = qpts;
            testCase.scattering_lengths = scattering_lengths;
            testCase.opts = opts;
            testCase.material_name = materials{1};
            testCase.force_constants = materials{2}(materials{3}{:});
        end
    end
end
