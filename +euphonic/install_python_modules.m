function install_python_modules()
    % A script to install (using `pip`) the required Python modules
    %
    % Usage:
    %
    % >>  euphonic.install_python_modules

    req_mods = required_modules;

    pipe = py.subprocess.PIPE;
    kwargs = pyargs('stdout', pipe, 'stderr', pipe);
    mods_kw = mod_str(req_mods);
    % Get Python execuable
    try
        % Pyenv only introduced in 2019b
        py_exe = pyenv().Executable;
    catch ME
        if (strcmp(ME.identifier,'MATLAB:UndefinedFunction'))
            % Pyversion is deprecated but use if pyenv not available
            [~, py_exe, ~] = pyversion(py_ex_path);
        else
            rethrow(ME);
        end
    end
    cmd = strjoin([{char(py_exe) '-m' 'pip' 'install'} mods_kw]);
    disp(cmd);
    out = py.subprocess.run(cmd, kwargs);
    if out.returncode ~= 0
        err = sprintf(char(uint8(out.stderr)));
        error(err);
    else
        disp(char(uint8(out.stdout)));
        verify_python_modules(req_mods{:});
        disp('Successfully installed Python modules');
    end
end
