function verify_test_data()
    % Checks that we have the test data in the submodule
    % and copies it to the correct folder.
    curdir = split(fileparts(mfilename('fullpath')), filesep);
    testdr = join([curdir; {'expected_output'}], filesep);
    if exist([testdr{1} filesep 'nacl_T300.mat'], 'file')
        return
    end
    submod = join([curdir(1:end-1); {'euphonic_horace'}], filesep);
    if ~exist([submod{1} filesep 'test' filesep 'expected_output'], 'dir')
        websave('main.zip', ... 
            'https://github.com/pace-neutrons/euphonic_horace/archive/main.zip');
        unzip('main.zip', 'main');
        dd = dir('main');
        for ii = 1:numel(dd)
            if strfind(dd(ii).name, 'euphonic_horace');
                copyfile(char(join({'main' dd(ii).name '*'}, filesep)), submod{1});
                break;
            end
        end
    end
    copyfile(char(join({submod{1} 'test' 'expected_output' '*'}, filesep)), ...
        'expected_output');
end
