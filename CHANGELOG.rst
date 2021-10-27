`Unreleased <https://github.com/pace-neutrons/horace-euphonic-interface/compare/v0.3.1...HEAD>`_
----------

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
