function verify_test_data()
    % Checks that we have the test data in the submodule
    % and copies it to the correct folder.
    curdir = split(fileparts(mfilename('fullpath')), filesep);
    testdr = join([curdir; {'expected_output'}], filesep);
    if exist([testdr{1} filesep 'nacl_T300.mat'], 'file')
        return
    end
    disp(['Test data files not found in ', testdr{1}]);
    submod = join([curdir(1:end-1); {'euphonic_sqw_models'}], filesep);
    if ~exist([submod{1} filesep 'test' filesep 'expected_output'], 'dir')
        test_data_addr = 'https://github.com/pace-neutrons/euphonic_sqw_models/archive/main.zip';
        disp(['Test data not found in ', submod{1}, ', downloading from ', test_data_addr]);
        websave('main.zip', test_data_addr);
        unzip('main.zip', 'main');
        dd = dir('main');
        for ii = 1:numel(dd)
            if strfind(dd(ii).name, 'euphonic_sqw_models');
                copyfile(char(join({'main' dd(ii).name '*'}, filesep)), submod{1});
                break;
            end
        end
    end
    disp(['Copying test data from ', submod{1}]);
    copyfile(char(join({submod{1} 'test' 'expected_output' '*'}, filesep)), ...
        'expected_output');
end
