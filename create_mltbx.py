import fileinput
import re
import shutil
import subprocess
from pathlib import Path

import update_module_versions
import versioneer

__version__ = versioneer.get_version()

HELPDOCSTR = """
    % Overloaded help command to display Python help in Matlab
    % To use it, please type
    %
    % >> import euphonic.help
    % >> help <topic>
    %
    % where <topic> is a Python class or method which has been wrapped for use in Matlab.
    % If the topic is not wrapped, the normal Matlab help is displayed.
"""


def replace_matlab_docstring(filename: Path, replacement_str: str):
    txt = filename.read_text(encoding="utf-8")
    comment = [m.start() for m in re.finditer(r'\n\s*%', txt)]
    newline = [m.start() for m in re.finditer(r'\n', txt)]
    idx = [cm for cm, nl in zip(comment, newline) if cm == nl]
    newtxt = txt[:idx[0]] + replacement_str + txt[idx[-1]:]
    filename.write_text(newtxt, encoding="utf-8")


def create_mltbx(base_path: Path):
    """
    Create toolbox assuming files relative to `base_path`
    """

    # replace version string as MATLAB only accepts numbers
    version = __version__.split('+')[0] if '+' in __version__ else __version__
    base_path = base_path.absolute()

    lpw_src = base_path / "light_python_wrapper"
    eup_src = base_path / "+euphonic"
    mdl_src = base_path / "euphonic_sqw_models" / "euphonic_sqw_models"
    mltbx_path = base_path / 'mltbx'
    lpw_dest = mltbx_path / "+light_python_wrapper"
    eup_dest = mltbx_path / "+euphonic"
    mdl_dest = mltbx_path / "euphonic_sqw_models" / "euphonic_sqw_models"

    with fileinput.FileInput(mltbx_path / 'horace_euphonic_interface.prj', inplace=True) as prj:
        for line in prj:
            # FileInput redirects stdout to the file, for inplace replacement
            print(line.replace('<param.version>1.0</param.version>',
                               f'<param.version>{version}</param.version>'), end='')

    update_module_versions.update_module_versions()
    # shutil.copytree expects destination to not exist
    for dest_folder in ['+light_python_wrapper', 'euphonic_sqw_models', '+euphonic']:
        if (dest := mltbx_path / dest_folder).is_dir():
            shutil.rmtree(dest)

    for file in ('LICENSE', 'CITATION.cff'):
        shutil.copy(file, mltbx_path)

    shutil.copytree(lpw_src / "+light_python_wrapper", lpw_dest)
    shutil.copytree(mdl_src, mdl_dest)
    shutil.copytree(eup_src, eup_dest)
    for fil in (lpw_src / "helputils").glob("*.m"):
        shutil.copy(fil, eup_dest)
    for fil in (lpw_src / "helputils/private").glob("*.m"):
        shutil.copy(fil, eup_dest / "private")

    replace_matlab_docstring(eup_dest / "help.m", HELPDOCSTR)
    replace_matlab_docstring(eup_dest / "doc.m", HELPDOCSTR.replace('help', 'doc'))


if __name__ == '__main__':
    curr_path = Path(__file__).parent
    create_mltbx(curr_path)
