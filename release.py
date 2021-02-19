import argparse
import json
import os
import re
import requests
import subprocess
import shutil
import versioneer
import euphonic_version
import update_dependencies

__version__ = versioneer.get_version()

def main():
    parser = get_parser()
    args = parser.parse_args()

    print(args)
    test = not args.notest
    if args.github:
        release_github(test)


def release_github(test=True):
    with open('CHANGELOG.rst') as f:
        changelog = f.read()
    hor_eu_interface_ver = 'v' + __version__
    changelog_ver = re.findall('`?(v\d+\.\d+\.\S+)\s', changelog)[0]
    if hor_eu_interface_ver != changelog_ver:
        #raise Exception((
        print((
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

    # Create a Matlab toolbox and upload it
    update_dependencies.pull_light_wrapper()
    update_dependencies.pull_euphonic_horace()
    create_mltbx()
    if test:
        print("Would upload mltx to github.")
    else:
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
        '--github',
        action='store_true',
        help='Release on Github')
    parser.add_argument(
        '--notest',
        action='store_true',
        help='Actually send/upload')
    return parser


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
    for dest_folder in ['+light_python_wrapper', 'euphonic_horace', '+euphonic']:
        if os.path.isdir('mltbx/' + dest_folder): shutil.rmtree('mltbx/' + dest_folder)
    shutil.copytree('light_python_wrapper/+light_python_wrapper', 'mltbx/+light_python_wrapper')
    shutil.copytree('euphonic_horace/euphonic_horace', 'mltbx/euphonic_horace/euphonic_horace')
    shutil.copytree('+euphonic', 'mltbx/+euphonic')
    subprocess.run(['matlab', '-batch', 
                    'matlab.addons.toolbox.packageToolbox("horace_euphonic_interface.prj", "horace_euphonic_interface.mltbx")'],
                   cwd='mltbx')


if __name__ == '__main__':
    main()

