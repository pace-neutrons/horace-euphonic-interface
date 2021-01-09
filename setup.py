import versioneer
try:
    from setuptools import setup
except ImportError:
    from distutils.core import setup

euphonic_ver = '0.3.2'

setup(name='horace_euphonic_interface',
      version=versioneer.get_version(),
      cmdclass=versioneer.get_cmdclass(),
      description='Phonon inelastic neutron spectra calculation using Horace and Euphonic',
      author='Rebecca Fair',
      author_email='rebecca.fair@stfc.ac.uk',
      url='https://github.com/pace-neutrons/horace-euphonic-interface',
      packages=['horace_euphonic_interface'],
      install_requires=['euphonic>=' + euphonic_ver],
     )

# Updates Matlab code with required versions
with open("+euphonic/private/required_modules.m", "w") as f:
    f.write(f"function out = required_modules()\n")
    f.write(f"    out = {{'euphonic', '{euphonic_ver}', ...\n")
    f.write(f"           'horace_euphonic_interface', '{versioneer.get_version()}'}};\n")
    f.write(f"end\n")
