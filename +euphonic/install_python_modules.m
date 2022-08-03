function install_python_modules()
    % A script to install (using `pip`) the required Python modules
    %
    % Usage:
    %
    % >>  euphonic.install_python_modules

    req_mods = required_modules;
    try
        verify_python_modules(req_mods{:});
    catch ME
        % Checks we have the right Python version (>=3.7)
        if strcmp(ME.identifier, 'euphonic_horace_interface:verify_python_modules:pythonVersion')
            rethrow(ME);
        end
    end
    pipe = py.subprocess.PIPE;
    kwargs = pyargs('stdout', pipe, 'stderr', pipe);
    mods_kw = {};
    for ii = 1:2:numel(req_mods)
        mods_kw = [mods_kw {[req_mods{ii} '==' req_mods{ii+1}]}];
    end
    out = py.subprocess.run([{py.sys.executable '-m' 'pip' 'install'} mods_kw], kwargs);
    if out.returncode ~= 0
        err = sprintf(char(uint8(out.stderr)));
        error(err);
    else
        fprintf(char(uint8(out.stdout)));
        disp('Successfully installed Python modules');
    end
end
