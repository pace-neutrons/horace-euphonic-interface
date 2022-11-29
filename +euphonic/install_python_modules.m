function install_python_modules()
    % A script to install (using `pip`) the required Python modules
    %
    % Usage:
    %
    % >>  euphonic.install_python_modules

    req_mods = required_modules;

    pipe = py.subprocess.PIPE;
    kwargs = pyargs('stdout', pipe, 'stderr', pipe);
    mods_kw = {};
    for ii = 1:2:numel(req_mods)
        mods_kw = [mods_kw req_mods{ii}];
    end
    % Get Python execuable
    try
        % Pyenv only introduced in 2019b
        py_exe = pyenv().Executable;
    catch ME
        if (strcmp(ME.identifier,'MATLAB:UndefinedFunction'))
            % Pyversion is deprecated but use if pyenv not available
            [ver, py_exe, isloaded] = pyversion(py_ex_path);
        else
            rethrow(ME);
        end
    end
    cmd = [{char(py_exe) '-m' 'pip' 'install'} mods_kw];
    disp(strjoin(cmd));
    out = py.subprocess.run(cmd, kwargs);
    if out.returncode ~= 0
        err = sprintf(char(uint8(out.stderr)));
        error(err);
    else
        fprintf(char(uint8(out.stdout)));
        verify_python_modules(req_mods{:});
        disp('Successfully installed Python modules');
    end
end
