import os
import re
import subprocess
import shutil
import glob

import versioneer
import euphonic_version

__version__ = versioneer.get_version()

HELPDOCSTR = '\n' \
    '    % Overloaded help command to display Python help in Matlab\n' \
    '    % To use it, please type\n' \
    '    %\n' \
    '    % >> import euphonic.help\n' \
    '    % >> help <topic>\n' \
    '    %\n' \
    '    % where <topic> is a Python class or method which has been wrapped for use in Matlab.\n' \
    '    % If the topic is not wrapped, the normal Matlab help is displayed.\n' \

def replace_matlab_docstring(filename, replacement_str):
    with open(filename) as f:
        txt = f.read()
    cm = [m.start() for m in re.finditer(r'\n\s*%', txt)]
    nl = [m.start() for m in re.finditer(r'\n', txt)]
    idx = [cm[idx] for idx in range(len(cm)) if cm[idx] == nl[idx]]
    newtxt = txt[:idx[0]] + replacement_str + txt[idx[-1]:]
    with open(filename, 'w') as f:
        f.write(newtxt)

def create_mltbx():
    import fileinput
    # replace version string
    version = __version__.split('+')[0] if '+' in __version__ else __version__  # Matlab only accepts numbers
    with fileinput.FileInput('mltbx/horace_euphonic_interface.prj', inplace=True) as prj:
        for line in prj:
            # FileInput redirect stdout to the file, for inplace replacement; end='' means don't add extra newlines
            print(line.replace('<param.version>1.0</param.version>', f'<param.version>{version}</param.version>'), end='')
    euphonic_version.update_euphonic_version()
    # shutil.copytree expects destination to not exist
    for dest_folder in ['+light_python_wrapper', 'euphonic_sqw_models', '+euphonic']:
        if os.path.isdir('mltbx/' + dest_folder): shutil.rmtree('mltbx/' + dest_folder)
    shutil.copytree('light_python_wrapper/+light_python_wrapper', 'mltbx/+light_python_wrapper')
    shutil.copytree('euphonic_sqw_models/euphonic_sqw_models', 'mltbx/euphonic_sqw_models/euphonic_sqw_models')
    shutil.copytree('+euphonic', 'mltbx/+euphonic')
    for fil in glob.glob('light_python_wrapper/helputils/*.m'): shutil.copy(fil, 'mltbx/+euphonic')
    for fil in glob.glob('light_python_wrapper/helputils/private/*.m'): shutil.copy(fil, 'mltbx/+euphonic/private')
    replace_matlab_docstring('mltbx/+euphonic/help.m', HELPDOCSTR)
    replace_matlab_docstring('mltbx/+euphonic/doc.m', HELPDOCSTR.replace('help', 'doc'))
    subprocess.run(['matlab', '-batch', 'create_mltbx'], cwd='mltbx')
    print('.mltbx created')

if __name__ == '__main__':
    create_mltbx()

