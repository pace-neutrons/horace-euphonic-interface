import os
import io
import zipfile
import requests
import shutil


def pull_light_wrapper():
    # Checks if the light_python_wrapper submodule has been fetched. If not, get it from github
    if not os.path.isfile('light_python_wrapper/+light_python_wrapper/light_python_wrapper.m'):
        gh_zip = 'https://github.com/pace-neutrons/light_python_wrapper/archive/master.zip'
        zipdata = requests.get(gh_zip, stream=True)
        zf = zipfile.ZipFile(io.BytesIO(zipdata.content))
        zf.extractall('.')
        rtfolder = zf.infolist()[0].filename
        shutil.copytree(rtfolder+'/+light_python_wrapper', 'light_python_wrapper/+light_python_wrapper')


def pull_euphonic_sqw_models():
    # Checks if the euphonic_sqw_models submodule has been fetched. If not, get it from github
    if not os.path.isfile('euphonic_sqw_models/euphonic_sqw_models/euphonic_wrapper.py'):
        import zipfile, io
        gh_zip = 'https://github.com/pace-neutrons/euphonic_sqw_models/archive/main.zip'
        zipdata = requests.get(gh_zip, stream=True)
        zf = zipfile.ZipFile(io.BytesIO(zipdata.content))
        zf.extractall('.')
        rtfolder = zf.infolist()[0].filename
        shutil.copytree(rtfolder+'/euphonic_sqw_models', 'euphonic_sqw_models/euphonic_sqw_models')
        shutil.copyfile(rtfolder+'/min_requirements.txt', 'euphonic_sqw_models/min_requirements.txt')


