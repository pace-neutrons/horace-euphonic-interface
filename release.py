import argparse
import json
import os
import re
import requests
import subprocess
import shutil
import versioneer

__version__ = versioneer.get_version()

def main():
    parser = get_parser()
    args = parser.parse_args()

    print(args)
    test = not args.notest
    if args.github:
        release_github(test)

    if args.pypi:
        release_pypi(test)


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
    pull_light_wrapper()
    pull_euphonic_horace()
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


def release_pypi(test=True):
    subprocess.run(['rm','-r','dist'])
    subprocess.run(['rm','-r','build'])
    subprocess.run(['python', 'setup.py', 'sdist'])
    if not test:
        subprocess.run(['twine', 'upload', 'dist/*'])


def get_parser():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        '--github',
        action='store_true',
        help='Release on Github')
    parser.add_argument(
        '--pypi',
        action='store_true',
        help='Release on PyPI')
    parser.add_argument(
        '--notest',
        action='store_true',
        help='Actually send/upload')
    return parser


def pull_light_wrapper():
    import os
    # Checks if the light_python_wrapper submodule has been fetched. If not, get it from github
    if not os.path.isfile('light_python_wrapper/+light_python_wrapper/light_python_wrapper.m'):
        import zipfile, io
        gh_zip = 'https://github.com/pace-neutrons/light_python_wrapper/archive/master.zip'
        zipdata = requests.get(gh_zip, stream=True)
        zf = zipfile.ZipFile(io.BytesIO(zipdata.content))
        zf.extractall('.')
        rtfolder = zf.infolist()[0].filename
        shutil.copytree(rtfolder+'/+light_python_wrapper', 'light_python_wrapper/+light_python_wrapper')


def pull_euphonic_horace():
    import os
    # Checks if the euphonic_horace submodule has been fetched. If not, get it from github
    if not os.path.isfile('euphonic_horace/euphonic_horace/euphonic_wrapper.py'):
        import zipfile, io
        gh_zip = 'https://github.com/pace-neutrons/euphonic_horace/archive/main.zip'
        zipdata = requests.get(gh_zip, stream=True)
        zf = zipfile.ZipFile(io.BytesIO(zipdata.content))
        zf.extractall('.')
        rtfolder = zf.infolist()[0].filename
        shutil.copytree(rtfolder+'/euphonic_horace', 'euphonic_horace/euphonic_horace')


def create_mltbx():
    import fileinput
    # replace version string
    version = __version__.split('+')[0] if '+' in __version__ else __version__  # Matlab only accepts numbers
    with fileinput.FileInput('mltbx/horace_euphonic_interface.prj', inplace=True) as prj:
        for line in prj:
            # FileInput redirect stdout to the file, for inplace replacement; end='' means don't add extra newlines
            print(line.replace('<param.version>1.0</param.version>', f'<param.version>{version}</param.version>'), end='')
    # shutil.copytree expects destination to not exist
    for dest_folder in ['+light_python_wrapper', 'euphonic_horace', '+euphonic']:
        if os.path.isdir('mltbx/' + dest_folder): shutil.rmtree('mltbx/' + dest_folder)
    shutil.copytree('light_python_wrapper/+light_python_wrapper', 'mltbx/+light_python_wrapper')
    shutil.copytree('euphonic_horace', 'mltbx/euphonic_horace')
    shutil.copytree('+euphonic', 'mltbx/+euphonic')
    subprocess.run(['matlab', '-batch', 
                    'matlab.addons.toolbox.packageToolbox("horace_euphonic_interface.prj", "horace_euphonic_interface.mltbx")'],
                   cwd='mltbx')


if __name__ == '__main__':
    main()

