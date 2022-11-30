import os
import fileinput

def get_module_versions():
    # gets the required module versions from `min_requirements.txt` file
    curdir = os.path.dirname(os.path.abspath(__file__))
    req_file = os.path.join(
        curdir, 'euphonic_sqw_models', 'min_requirements.txt')
    if not os.path.isfile(req_file):
        from update_dependencies import update_submodules
        update_submodules('euphonic_sqw_models')
    with open(req_file, 'r') as minreq:
        reqstrs = minreq.read().splitlines()
    reqmods = []
    for req in reqstrs:
        reqspl = req.split('>=')
        if len(reqspl) == 1 and 'euphonic' in req:
            # Euphonic is a special case, can define 'euphonic>ver'
            # which means Euphonic is between versions
            reqspl = req.split('>')
        if len(reqspl) == 1:
            raise ValueError(
                f'Unexpected module version {req} in {req_file}')
        reqmods += [req.strip() for req in reqspl]
    return reqmods

def update_module_versions():
    curdir = os.path.dirname(os.path.abspath(__file__))
    verstrs = [f"'{verstr}'" for verstr in get_module_versions()]
    vercell = f"{{{', '.join(verstrs)}}}"
    with fileinput.FileInput(curdir+'/+euphonic/private/required_modules.m',
                             inplace=True) as reqmod:
        for line in reqmod:
            # FileInput redirect stdout to the file, for inplace replacement;
            # end='' means don't add extra newlines
            print(line.replace('{}', vercell), end='')
