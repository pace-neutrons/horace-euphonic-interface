import os
import fileinput


def get_euphonic_version():
    # gets the required euphonic version from `min_requirements.txt` file
    curdir = os.path.dirname(os.path.abspath(__file__))
    req_file = os.path.join(curdir, 'euphonic_horace', 'min_requirements.txt')
    if not os.path.isfile(req_file):
        import update_dependencies
        update_dependencies.pull_euphonic_horace()
    with open(req_file, 'r') as minreq:
        verstr = [req for req in minreq if 'euphonic' in req]
    return verstr[0].split('=')[1].strip()


def update_euphonic_version():
    curdir = os.path.dirname(os.path.abspath(__file__))
    with fileinput.FileInput(curdir+'/+euphonic/private/required_modules.m', inplace=True) as reqmod:
        for line in reqmod:
            # FileInput redirect stdout to the file, for inplace replacement; end='' means don't add extra newlines
            print(line.replace('TO_BE_DETERMINED', f'{get_euphonic_version()}'), end='')
