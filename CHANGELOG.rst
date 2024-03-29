`Unreleased <https://github.com/pace-neutrons/horace-euphonic-interface/compare/v1.1.0...HEAD>`_
----------

`v1.1.0 <https://github.com/pace-neutrons/horace-euphonic-interface/compare/v1.0.0...v1.1.0>`_
------

- New Features:

  - You can now perform linear interpolation of phonon frequencies and
    eigenvectors with the `Brille <https://brille.github.io/stable/index.html>`_
    library using the new ``euphonic.brille.BrilleInterpolator``
    object. This should provide performance improvements for large unit
    cells which require the dipole correction.

- Dependency changes:

  - Euphonic version dependency increased from >=0.6.0 to >=1.2.0

`v1.0.0 <https://github.com/pace-neutrons/horace-euphonic-interface/compare/v0.3.3...v1.0.0>`_
------

- Changes:

  - ``psutil`` has been added as a Python dependency for automatic chunking

- Improvements:

  - ``n_threads`` will now automatically be converted to an integer (using e.g.
    ``int32(4)`` is no longer needed)
  - Warn rather than error if the incorrect Python version or Python module
    versions are used
  - If ``chunk`` isn't provided to ``euphonic.CoherentCrystal``, a recommended chunk
    size will be set depending on the available memory
  - ``install_python_modules.m`` will now install the latest version of dependencies
    instead of the oldest

- Bug fixes:

  - In some distributions of MATLAB the automatic conversion from Numpy ``ndarray`` using
    MATLAB's ``double`` does not work. If it fails, convert to a regular ``py.array``
    first, this should be more reliable.
  - In some MATLAB versions ``py.sys.executable`` actually points to the MATLAB executable
    so the ``install_python_modules`` script wouldn't work. This has been fixed.

`v0.3.3 <https://github.com/pace-neutrons/horace-euphonic-interface/compare/v0.3.2...v0.3.3>`_
------

- Improvements:

  - A ``CITATION.cff`` file has been created and  is now bundled with the ``.mltbx`` distribution
  - The ``LICENSE`` file is now bundled with the ``.mltbx`` distribution
  - Only warn once about slow Numpy array conversion with old Matlab versions

- Bug fixes:

  - Fix bug which made the required version checks fail with Euphonic 1.0.0
  - Fix bug with Numpy array conversion with Matlab 2018

`v0.3.2 <https://github.com/pace-neutrons/horace-euphonic-interface/compare/v0.3.1...v0.3.2>`_
----------

- Bug fixes:

  - Use of temperature=0 will now calculate the 0K Debye-Waller and Bose
    population factors - previously these temperature dependent effects
    were not calculated at 0K

- Improvements:

  - There are now ``help`` and ``doc`` commands which override the built-in
    Matlab commands to display richer help information (from the Python
    on-line documentation) for Euphonic commands.
    To use them, you must first import them with :code:`import euphonic.help`
    or :code:`import euphonic.doc` to override the built-in commands.
    Then use it as normal, e.g. :code:`help euphonic.ForceConstants`.
    If this is used without the import, the original Matlab help is displayed
    which has been modified to suggest that the import is used.

`v0.3.1 <https://github.com/pace-neutrons/horace-euphonic-interface/compare/v0.3.0...v0.3.1>`_
------

- Improvements:

  - There is a new ``frequency_scale`` argument to ``horace_disp`` which
    allows the output frequencies to be scaled

`v0.3.0 <https://github.com/pace-neutrons/horace-euphonic-interface/compare/v0.2.2...v0.3.0>`_
------

- Dependency changes:

  - Euphonic version dependency increased from >=0.5.0 to >=0.6.0

- Breaking changes:

  - The default units of ``StructureFactor.structure_factors`` in Euphonic have been
    changed from ``angstrom**2`` per unit cell to ``mbarn`` per sample atom, and are
    now in absolute units including a previously omitted 1/2 factor. So the structure
    factors produced by ``CoherentCrystal.horace_disp`` have increased by a factor of
    ``1e11/(2*N_atoms)``

- Other changes:

  - The ``eta_scale`` keyword argument to ``CoherentCrystal`` has been deprecated,
    ``dipole_parameter`` should be used instead
  - A Python ValueError will now be raised if an unrecognised keyword argument is
    passed to ``CoherentCrystal``

`v0.2.2 <https://github.com/pace-neutrons/horace-euphonic-interface/compare/v0.2.1...v0.2.2>`_
------

This release has no code changes, this just updates the IDAaaS installation documentation

`v0.2.1 <https://github.com/pace-neutrons/horace-euphonic-interface/compare/v0.2.0...v0.2.1>`_
----------

This release has no code changes, this update is only to fix the .mltbx upload to the MATLAB File Exchange

`v0.2.0 <https://github.com/pace-neutrons/horace-euphonic-interface/compare/v0.1.0...v0.2.0>`_
----------

There has been a major refactor, which means changes to how
Horace-Euphonic-Interface is installed. There are also major changes
to how Euphonic is used, the API has been updated to make it more
object-oriented.

- Dependency changes:

  - Euphonic version dependency increased to >=0.5.0

- Installation changes:

  - Horace-euphonic-interface is now distributed as a Matlab toolbox (``.mltbx``)
    which is available in the `Matlab File Exchange <https://www.mathworks.com/matlabcentral/fileexchange/>`_ as an Add-On

- Usage changes:

  - ``euphonic_sf`` has been removed
  - ``euphonic_on`` has been removed
  - Force constants are now a separate object (``ForceConstants``) rather than
    passing these arguments to ``euphonic_sf``
  - The model parameters are set in a ``CoherentCrystal`` model object, rather than
    passing these parameters to ``euphonic_sf``
  - The function handle to be passed to ``disp2sqw_eval`` is ``CoherentCrystal.horace_disp`` rather than ``euphonic_sf``
  - The ``dw_grid`` argument has been renamed to ``debye_waller_grid``
  - ``fall_back_on_python`` argument has been removed as this has been removed in Euphonic

For more detailed help see the `documentation <https://horace-euphonic-interface.readthedocs.io/en/latest/>`_

`v0.1.0 <https://github.com/pace-neutrons/horace-euphonic-interface/compare/81607231b...v0.1.0>`_
------

- First release
