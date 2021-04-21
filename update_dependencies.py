import os
import zipfile
import shutil
import subprocess
from urllib.request import urlretrieve


def pull_light_wrapper():
    # Checks if the light_python_wrapper submodule has been fetched. If not, get it from github
    if not os.path.isfile('light_python_wrapper/+light_python_wrapper/light_python_wrapper.m'):
        zip_name = 'master.zip'
        gh_zip = 'https://github.com/pace-neutrons/light_python_wrapper/archive/' + zip_name
        urlretrieve(gh_zip, zip_name)
        zf = zipfile.ZipFile(zip_name)
        zf.extractall('.')
        rtfolder = zf.infolist()[0].filename
        shutil.copytree(rtfolder+'/+light_python_wrapper', 'light_python_wrapper/+light_python_wrapper')


def pull_euphonic_sqw_models():
    # Checks if the euphonic_sqw_models submodule has been fetched. If not, get it from github
    if not os.path.isfile('euphonic_sqw_models/euphonic_sqw_models/euphonic_wrapper.py'):
        zip_name = 'main.zip'
        gh_zip = 'https://github.com/pace-neutrons/euphonic_sqw_models/archive/' + zip_name
        urlretrieve(gh_zip, zip_name)
        zf = zipfile.ZipFile(zip_name)
        zf.extractall('.')
        rtfolder = zf.infolist()[0].filename
        shutil.copytree(rtfolder+'/euphonic_sqw_models', 'euphonic_sqw_models/euphonic_sqw_models')
        shutil.copyfile(rtfolder+'/min_requirements.txt', 'euphonic_sqw_models/min_requirements.txt')


def update_submodules(submodule=None):
    curdir = os.path.dirname(os.path.abspath(__file__))
    submodules = {
            'euphonic_sqw_models':
                {'required_path': os.path.join(
                    curdir,
                    os.path.join('euphonic_sqw_models', 'euphonic_sqw_models', 'euphonic_wrapper.py'))},
            'light_python_wrapper':
                {'required_path': os.path.join(
                    curdir,
                    os.path.join('light_python_wrapper', '+light_python_wrapper', 'light_python_wrapper.m'))}}
    if submodule is not None:
        submodules = {submodule: submodules[submodule]}
    for key, val in submodules.items():
        if not os.path.isfile(val['required_path']):
            cmd = 'git submodule update --init ' + key
            print(cmd)
            ret = subprocess.run(cmd)
            ret.check_returncode()
        else:
            print(f"{val['required_path']} already present, not updating {key}")
