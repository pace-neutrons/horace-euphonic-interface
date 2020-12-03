import argparse
import json
import os
import re
import requests
import subprocess

from get_hor_eu_interface_version import get_version


def main():
    parser = get_parser()
    args = parser.parse_args()

    test = not args.notest
    if args.github:
        release_github(test)


def release_github(test=True):
    with open('CHANGELOG.rst') as f:
        changelog = f.read()
    hor_eu_interface_ver = 'v' + get_version()
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


if __name__ == '__main__':
    main()
