addpath('..')
if ispc
    ver = version('-release');
    if ver == '2019b'
        pyversion 'C:\Programming\miniconda3\envs\py_2019b64\python'
    elseif ver == '2018b'
        pyversion 'C:\Programming\miniconda3\envs\py_2018b64\python'
    else
	fprintf('Unexpected MATLAB version %s\n', ver);
    end
else
    pyversion '/home/jenkins/.conda/envs/py/bin/python'
    py.sys.setdlopenflags(int32(10))
end
euphonic_on
