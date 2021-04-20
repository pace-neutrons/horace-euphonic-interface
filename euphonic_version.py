import os
import fileinput

from update_dependencies import update_submodules

def get_euphonic_version():
    update_submodules('euphonic_sqw_models')
    # gets the required euphonic version from `min_requirements.txt` file
    curdir = os.path.dirname(os.path.abspath(__file__))
    req_file = os.path.join(curdir, 'euphonic_sqw_models', 'min_requirements.txt')
    with open(req_file, 'r') as minreq:
        verstr = [req for req in minreq if 'euphonic' in req]
        if len(verstr) != 1:
            raise ValueError(
                f'Incorrect number of euphonic versions in {req_file}')
        else:
            verstr = verstr[0]
        if verstr.find('=') == -1:
            # No '=', so is using unreleased version
            if verstr.find('>') == -1:
                raise ValueError(
                    f'Unexpected euphonic version {verstr} in {req_file}')
            return '>' + verstr.split('>')[1].strip()
        else:
            return verstr.split('=')[1].strip()

def update_euphonic_version():
    curdir = os.path.dirname(os.path.abspath(__file__))
    with fileinput.FileInput(curdir+'/+euphonic/private/required_modules.m', inplace=True) as reqmod:
        for line in reqmod:
            # FileInput redirect stdout to the file, for inplace replacement; end='' means don't add extra newlines
            print(line.replace('TO_BE_DETERMINED', f'{get_euphonic_version()}'), end='')
