=========================
horace-euphonic-interface
=========================

This is a simple interface to allow simulation of inelastic neutron scattering
data from phonons in `Horace <https://horace.isis.rl.ac.uk/>`_ using
`Euphonic <https://euphonic.readthedocs.io>`_. This is done using Horace
`simulation functions <http://horace.isis.rl.ac.uk/Simulation>`_.

.. contents:: :local:

General Installation
--------------------

1. Prerequisites
^^^^^^^^^^^^^^^^
Ensure you have both Horace, Euphonic and the Python package ``psutil`` installed:

- `Horace docs <https://horace.isis.rl.ac.uk/>`_ 
- `Euphonic docs <https://euphonic.readthedocs.io>`_
- `psutil <https://pypi.org/project/psutil/>`_

2. Set up Python in Matlab
^^^^^^^^^^^^^^^^^^^^^^^^^^

The Python executable that you installed Euphonic with needs to be specified
in MATLAB. You can find the executable location in Python with:

.. code-block:: python

  >>> import sys
  >>> print(sys.executable)

You can then set this executable in MATLAB (2019b or later) using:

.. code-block:: MATLAB

  >> pyenv('Version', '/path/to/python')

Or in MATLAB 2019a or earlier:

.. code-block:: MATLAB

  >> pyversion('/path/to/python')

.. Note::

  The Python version used in Matlab can only be changed if it has not yet been
  loaded. If you have already installed Horace-Euphonic-Interface, Python might
  be automatically loaded on startup. To prevent this, disable
  Horace-Euphonic-Interface first in **Add-Ons > Manage Add-Ons** then click the
  :math:`\vdots` symbol to the right of the add-on to bring up the settings,
  and untick the **Enabled** box, then restart Matlab. Python will no longer be
  loaded. Remember to re-enable Horace-Euphonic-Interface afterwards.

3. Download and Install
^^^^^^^^^^^^^^^^^^^^^^^

**Latest version (recommended)**

Horace-Euphonic-Interface is packaged as a Matlab toolbox (``.mltbx``), which
allows easy installation from a single file as a Matlab Add-On. In Matlab,
go to the **Home** tab, and in the **Environment** section, click **Add-Ons**,
and then **Get Add-Ons**. Search for **horace-euphonic-interface**, select it
and then click **Add > Add to MATLAB**. That's it!

See `here <https://www.mathworks.com/help/matlab/matlab_env/get-add-ons.html>`_
for more information on Matlab Add-Ons.

**Older versions**

The ``.mltbx`` file for each release is also available at
https://github.com/pace-neutrons/horace-euphonic-interface/releases.
Open the ``.mltbx`` file in Matlab and it should automatically be installed.

4. Test installation
^^^^^^^^^^^^^^^^^^^^
To test everything has been installed ok, try:

.. code-block:: matlab

  >> euphonic.ForceConstants

If everything worked, you should see the Python type description
:code:`<class 'euphonic.force_constants.ForceConstants'>`.

IDAaaS Installation
-------------------

Euphonic is installed in a Python virtual environment at
``/opt/euphonic`` and ``horace-euphonic-interface``
is already installed in Matlab as an add-on. To use Horace-Euphonic-Interface,
you just have to make sure the Python version you are using in Matlab has
a compatible version of Euphonic installed. To avoid Python/Matlab library
collisions, you also need to set some library loading flags and import
Euphonic as soon as Matlab is started. To do this, just add the following
to your ``startup.m``:

.. code-block:: matlab

  pyenv('Version', '/opt/euphonic/bin/python3');
  py.sys.setdlopenflags(int32(10));
  py.importlib.import_module('euphonic');

Usage
-----

Quick Guide
^^^^^^^^^^^

To view the available functions and classes, try:

.. code-block:: matlab

  import euphonic.help
  help euphonic
  import euphonic.doc
  doc euphonic

Because Euphonic is actually a Python program which is wrapped to be used in Matlab,
its online documentation is in Python, and the default Matlab ``help`` function
is not able to read this.
The ``import`` commands above instead overrides the default ``help`` and ``doc`` 
functions to use the Python help system for Euphonic functions instead.
(You can also use :code:`import euphonic.help euphonic.doc` instead of using
two separate ``import`` commands.)


**1. Read force constants**

First, the force constants must be read. The usage is very similar to Euphonic,
for example to read a CASTEP ``.castep_bin`` file:

.. code-block:: matlab

  fc = euphonic.ForceConstants.from_castep('quartz.castep_bin')

Or, to read from Phonopy files:

.. code-block:: matlab

  fc = euphonic.ForceConstants.from_phonopy('path', 'quartz', ...
                                            'summary_name', 'phonopy.yaml')

To get help on these functions type:

.. code-block:: matlab

   help euphonic.ForceConstants.from_castep
   help euphonic.ForceConstants.from_phonopy
   help euphonic.ForceConstants.from_json_file
   help euphonic.ForceConstants.from_dict

You can also type :code:`help euphonic` or :code:`doc euphonic` and follow the hyperlinks.

Note that in Matlab usage, a Matlab ``struct`` should be used for the dictionary
in the ``from_dict`` function.

**2. Set up model**

Next, the model must be set up. Currently, only the ``CoherentCrystal`` model
is available. The force constants must be passed in, then any other optional
parameters. For example:

.. code-block:: matlab

  coh_model = euphonic.CoherentCrystal(...
     fc, ...
     'conversion_mat', [1 0 0; 0 1 0; 0 0 -1],
     'debye_waller_grid', [6 6 6], ...
     'temperature', 100, ...
     'asr', 'reciprocal', ...
     'use_c', true);

To see all the available optional parameters, try one of:

.. code-block:: matlab

  help euphonic.CoherentCrystal
  doc euphonic.CoherentCrystal

.. note::

  **conversion_mat**

  Pay particular attention to this parameter, this is a 3x3 matrix to convert
  from the q-points in Horace to the q-points in the modelling code. This will
  be required if you've used a different unit cell convention/orientation in
  Horace and your modelling code, and will depend on the cells chosen. If
  set incorrectly, the results will not make sense (or worse, may happen to
  make sense at first in certain cuts due to symmetry, but give incorrect
  results in other cuts later on!)

**3. Simulate cut**

In Horace, the ``disp2sqw_eval`` simulation function is used to simulate
experimental data with Euphonic. This requires a function handle, which is provided
by ``CoherentCrystal.horace_disp``. Help on the ``horace_disp`` function can
be seen by with ``help euphonic.CoherentCrystal.horace_disp``.

``horace_disp`` has 2 optional arguments, ``intensity_scale`` and ``frequency_scale``
which can be used to multiply the intensities and frequencies by a constant scaling
factor. These can be used as positional arguments (note they must be in the correct
order). For example:

.. code-block:: matlab

  intensity_scale = 100;
  frequency_scale = 0.9
  effective_fwhm = 1;

  cut_sim = disp2sqw_eval(cut, @coh_model.horace_disp, [intensity_scale, frequency_scale], effective_fwhm);

They can also be used as named arguments, for example:

.. code-block:: matlab

  iscale = 100;
  fscale = 0.9
  effective_fwhm = 1;

  cut_sim = disp2sqw_eval(cut, @coh_model.horace_disp, {'intensity_scale', iscale, 'frequency_scale', fscale}, effective_fwhm);

If the scaling parameters are to be used in fitting (e.g. in Multifit or Tobyfit), they must be used as positional arguments, for example:

.. code-block:: matlab

  iscale = 100;
  fcale = 0.9
  fwhm = 1;

  kk = multifit_sqw(cut);
  kk = kk.set_fun(@disp2sqw, {@coh_model.horace_disp, [iscale, fscale], fwhm});
  cut_sim = kk.fit();


Full Example
^^^^^^^^^^^^

An example script simulating a simple cut is below:

.. code-block:: matlab

  % Read in experimental cut
  cut = read_horace('quartz.d2d');

  % Read force constants
  fc = euphonic.ForceConstants.from_castep('quartz.castep_bin')

  % Set up model
  coh_model = euphonic.CoherentCrystal(...
     fc, ...
     'conversion_mat', [1 0 0; 0 1 0; 0 0 -1],
     'debye_waller_grid', [6 6 6], ...
     'temperature', 100, ...
     'dipole_parameter', 0.75, ...
     'asr', 'reciprocal', ...
     'use_c', true, ...
     'n_threads', 4);


  % Simulate
  intensity_scale = 100;
  frequency_scale = 0.9;
  effective_fwhm = 1;
  cut_sim = disp2sqw_eval(...
     cut, @coh_model.horace_disp, {'intensity_scale', intensity_scale, 'frequency_scale', frequency_scale}, effective_fwhm);

  % Plot
  plot(cut_sim);


Faster Interpolation with Brille
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

From version ``1.2.0``, Euphonic can use the `Brille <https://brille.github.io/>`_ library to perform linear (rather than Fourier) interpolation of phonon frequencies and eigenvectors.
Linear interpolation may be less accurate than the Fourier interpolation performed by ``ForceConstants``,
but should be faster for large unit cells, particularly those that require the expensive dipole correction calculation.
You should test this on your particular machine and material first to see if it provides a performance benefit.
For more details on how this works, and what the various options mean, see the `Euphonic BrilleInterpolator docs <https://euphonic.readthedocs.io/en/stable/brille-interpolator.html>`_

A ``BrilleInterpolator`` object can be created from a ``ForceConstants`` object, and can then be used in ``horace_disp`` just like ``ForceConstants``.
A full example showing this is below:

.. code-block:: matlab

  % Read in experimental cut
  cut = read_horace('quartz.d2d');

  % Read force constants
  fc = euphonic.ForceConstants.from_castep('quartz.castep_bin')

  % Create BrilleInterpolator from the force constants
  % Note that any arguments you would pass to
  % ForceConstants.calculate_qpoint_phonon_modes are passed here as
  % 'interpolation_kwargs' to be used when creating the Brille grid
  bri = euphonic.BrilleInterpolator.from_force_constants(...
      fc, ...
      'grid_npts', 5000, ...
      'interpolation_kwargs', struct('dipole_parameter', 0.75, ...
                                     'use_c', true, ...
                                     'n_threads', 4, ...));

  % Set up model
  % Pass in BrilleInterpolator here instead of force constants
  coh_model = euphonic.CoherentCrystal(...
     bri, ...
     'conversion_mat', [1 0 0; 0 1 0; 0 0 -1],
     'debye_waller_grid', [6 6 6], ...
     'temperature', 100, ...
     'useparallel', true, ...
     'threads', 4);

  % Simulate
  intensity_scale = 100;
  frequency_scale = 0.9;
  effective_fwhm = 1;
  cut_sim = disp2sqw_eval(...
     cut, @coh_model.horace_disp, {'intensity_scale', intensity_scale, 'frequency_scale', frequency_scale}, effective_fwhm);

  % Plot
  plot(cut_sim);

Performance and Memory Tips
^^^^^^^^^^^^^^^^^^^^^^^^^^^

The following are a few tips to help make sure you have the optimum settings
for the type of work you're doing and your computing resources.

**Number of Threads**

Euphonic will make use of the C Extension by default, and automatically choose
the number of threads using the Python function ``multiprocessing.cpu_count``.
However, this can be overridden by the ``use_c`` and ``n_threads`` arguments
to ``CoherentCrystal`` (or ``useparallel`` and ``threads`` if you're using
``BrilleInterpolator``). Ensure that if these arguments are used, they are
appropriate to the computing resource you are using. Generally ``use_c``
should be  ``true`` and ``n_threads`` should be the same as the number of
cores (or the same as the number of logical cores if your system has
hyperthreading).

**Chunking**

The phonon eigenvectors, which are an intermediate step in calculating
the scattering intensities, are particularly memory intensive, requiring
:math:`18n^2` floating point numbers per q-point, where :math:`n` is the
number of atoms in the unit cell of your calculation. To reduce memory
consumption, the intensity calculation can be chunked with the ``chunk``
argument to ``CoherentCrystal``. This defines the number of q-points that are
calculated at once. Generally it is best to use the largest chunk you can get
away with based on the amount of memory available and the number of atoms in
the unit cell, but this depends on the system architecture. If no ``chunk``
is provided to ``CoherentCrystal``, a recommended chunk size will
automatically be set depending on the available memory. This estimate is
conservative to cover most use-cases and avoid running out of memory (which
can cause  mysterious crashes!). Therefore it is possible on some systems
using a higher chunk size might be slightly more efficient, but it is a good
starting estimate.

**Reducing Q-points**

The most time consuming part of the intensity calculation is the calculation
of the phonon frequencies and eigenvectors. Fortunately these are periodic
from one Brillouin Zone to the next. If the ``reduce_qpts`` argument to
``CoherentCrystal`` is set to ``true`` (this is the default), Euphonic will
look for q-points in other Brillouin Zones e.g. if there are points
``[0.5, 0.5, 0.]`` and ``[1.5, 1.5, 2.]`` Euphonic will only calculate
frequencies/eigenvectors for one of those q-points. However, there is some
overhead to finding these q-points, and Euphonic will only look at q-points
in the same chunk, so setting ``reduce_qpts`` to ``true`` will not always
be beneficial. It is most likely to be useful if you are simulating a ``dnd``
object with commensurate bin spacing. If you are simulating per pixel, or
are using Tobyfit to apply resolution convolution, the q-points are likely
to be irregular so ``reduce_qpts`` may not provide a benefit.

**Dipole Parameter**

If your simulation cell is polar (i.e. you have Born charges and dielectric
permittivity tensors), there is an extra computationally expensive correction
that must be applied when calculating the phonon frequencies and eigenvectors.
This correction is based on an Ewald sum, so includes both real space and
reciprocal space sums. The limit of these sums can be tuned so that the
optimum balance of real and reciprocal space terms is used to reduce the
computation required. This can be done with the ``dipole_parameter`` argument
to ``CoherentCrystal``. Euphonic has a Python command-line tool,
`euphonic-optimise-dipole-parameter <https://euphonic.readthedocs.io/en/stable/dipole-parameter-script.html>`_
which can help to tune this argument.

**Use Linear Interpolation with Brille**

See `Faster Interpolation with Brille`_


.. toctree::
   :hidden:
   :maxdepth: 2

   release-notes
