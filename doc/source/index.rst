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

  >> help(euphonic.ForceConstants)

IDAaaS Installation
-------------------

Euphonic is already installed in a Python virtual environment at
``/usr/local/virtualenvs/euphonicenv`` and ``horace-euphonic-interface``
is available at ``/usr/local/mprogs``. To make use of these, add the following to
your ``startup.m``:

.. code-block:: matlab

  addpath('/usr/local/mprogs/horace-euphonic-interface')
  pyversion '/usr/local/virtualenvs/euphonicenv/bin/python3'

Usage
-----

Quick Guide
^^^^^^^^^^^

To view the available functions and classes, try:

.. code-block:: matlab

  help euphonic

**1. Read force constants**

First, the force constants must be read. The usage is very similar to Euphonic,
for example to read a CASTEP ``.castep_bin`` file:

.. code-block:: matlab

  fc = euphonic.ForceConstants.from_castep('quartz.castep_bin')

Or, to read from Phonopy files:

.. code-block:: matlab

  fc = euphonic.ForceConstants.from_castep('path', 'phonopy.yaml')

**2. Set up model**

Next, the model must be set up. Currently, the ``CoherentCrystal`` model
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

To see all the available optional parameters, try:

.. code-block:: matlab

  help(euphonic.CoherentCrystal)

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
by ``CoherentCrystal.horace_disp``:

.. code-block:: matlab

  scale_factor = 1e12;
  effective_fwhm = 1;

  cut_sim = disp2sqw_eval(cut, @coh_model.horace_disp, {scale_factor}, effective_fwhm);


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
  scale_factor = 1e12;
  effective_fwhm = 1;
  cut_sim = disp2sqw_eval(...
     cut, @coh_model.horace_disp, {scale_factor}, effective_fwhm);

  % Plot
  plot(cut_sim);

.. toctree::
   :hidden:
   :maxdepth: 2

   release-notes
