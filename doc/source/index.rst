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
Ensure you have both Horace and Euphonic installed:

- `Horace docs <https://horace.isis.rl.ac.uk/>`_ 
- `Euphonic docs <https://euphonic.readthedocs.io>`_

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
``/usr/local/virtualenvs/euphonicenv`` and ``horace-euphonic-interface``
is already installed in Matlab as an add-on. To use Horace-Euphonic-Interface,
you just have to make sure the Python version you are using in Matlab has
a compatible version of Euphonic installed. To do this, just add the following
to your ``startup.m``:

.. code-block:: matlab

  pyenv('Version', '/usr/local/virtualenvs/euphonicenv/bin/python3');
  py.sys.setdlopenflags(int32(10));

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
be seen by with ``help(euphonic.CoherentCrystal)``, under the ``Methods`` heading.

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
     'asr', 'reciprocal', ...
     'use_c', true);


  % Simulate
  intensity_scale = 100;
  frequency_scale = 0.9;
  effective_fwhm = 1;
  cut_sim = disp2sqw_eval(...
     cut, @coh_model.horace_disp, {'intensity_scale', intensity_scale, 'frequency_scale', frequency_scale}, effective_fwhm);

  % Plot
  plot(cut_sim);

.. toctree::
   :hidden:
   :maxdepth: 2

   release-notes
