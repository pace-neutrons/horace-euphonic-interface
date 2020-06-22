addpath('..')
if ispc
    pyversion 'C:\Programming\miniconda3\envs\py\python'
else
    pyversion '/home/jenkins/.conda/envs/py/bin/python'
    py.sys.setdlopenflags(int32(10))
end
euphonic_on
