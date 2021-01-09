function install_python_modules()
    try
        req_mods = required_modules;
        verify_python_modules(req_mods{:});
    catch ME
        % Checks we have the right Python version (>=3.6)
        if ~strcmp(ME.identifier, 'euphonic_horace_interface:verify_python_modules:pythonVersion')
            rethrow(ME);
        end
    end
    pipe = py.subprocess.PIPE;
    kwargs = pyargs('stdout', pipe, 'stderr', pipe);
    out = py.subprocess.run({py.sys.executable '-m' 'pip' 'install' 'euphonic' 'horace-euphonic-interface'}, kwargs);
    if out.returncode ~= 0
        err = sprintf(char(uint8(out.stderr)));
        error(err);
    else
        fprintf(char(uint8(out.stdout)));
        disp('Successfully installed Python modules');
    end
end
