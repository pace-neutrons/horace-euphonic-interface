import argparse
import json
import os
import re
import requests
import subprocess
import shutil
import versioneer
import euphonic_version
from update_dependencies import update_submodules

__version__ = versioneer.get_version()

def main():
    parser = get_parser()
    args = parser.parse_args()
    print(args)

    update_submodules()
    if args.github:
        args.create_toolbox = True

    if args.create_toolbox:
        create_mltbx()

    test = not args.notest
    if args.github:
        release_github(test)

def check_submodule_version(submodule):
    """
    Check release version of Horace-Euphonic-Interface depends
    on release versions of submodules
    """
    ret = subprocess.run('git tag --points-at HEAD',
                         cwd=submodule,
                         capture_output=True)
    ver = ret.stdout.decode('utf-8').strip()
    if ver == '':
        raise Exception(f'Submodule {submodule} is not a tagged (release) '
                        f'version. A release version of Horace-Euphonic-Interface '
                        f'should depend on release versions of its submodules')


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
    subprocess.run(['matlab', '-batch', 'create_mltbx'], cwd='mltbx')
    print('.mltbx created')


def release_github(test=True):
    submodules = ['light_python_wrapper', 'euphonic_sqw_models']
    for submodule in submodules:
        check_submodule_version(submodule)

    with open('CHANGELOG.rst') as f:
        changelog = f.read()
    hor_eu_interface_ver = 'v' + __version__
    changelog_ver = re.findall('`?(v\d+\.\d+\.\S+)\s', changelog)[0]
    if hor_eu_interface_ver != changelog_ver:
        raise Exception((
            f'VERSION and CHANGELOG.rst version mismatch!\n'
            f'VERSION: {hor_eu_interface_ver}\nCHANGELOG.rst: '
            f'{changelog_ver}'))
    desc = re.search('`v\d+\.\d+\.\S+.*?^-+\n(.*)', changelog,
                     re.DOTALL | re.MULTILINE).groups()[0].strip()

    payload = {
        "tag_name": changelog_ver,
        "target_commitish": "master",
        "name": changelog_ver,
        "body": desc,
        "draft": False,
        "prerelease": False
    }
    if test:
        print(payload)
    else:
        response = requests.post(
            'https://api.github.com/repos/pace-neutrons/horace-euphonic-interface/releases',
            data=json.dumps(payload),
            headers={"Authorization": "token " + os.environ["GITHUB_TOKEN"]})
        print(response.text)

    # Upload Matlab toolbox
    if not test:
        upload_url = response.json().get('upload_url')
        response = requests.post(
            upload_url,
            data = open('mltbx/horace_euphonic_interface.mltbx', 'rb'),
            headers = {"Content-Type": 'application/octet-stream', 
                       "Authorization": "token " + os.environ["GITHUB_TOKEN"]},
        )
        print(response.text)


def get_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--create-toolbox',
        action='store_true',
        help=('Create .mltbx file. This is automatically set to True if '
              '--github is used'))
    parser.add_argument(
        '--github',
        action='store_true',
        help='Release on Github')
    parser.add_argument(
        '--notest',
        action='store_true',
        help='Actually send/upload')
    return parser



if __name__ == '__main__':
    main()

