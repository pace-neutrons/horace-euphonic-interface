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

First ensure you have both Horace and Euphonic installed:

- `Horace docs <https://horace.isis.rl.ac.uk/>`_ 
- `Euphonic docs <https://euphonic.readthedocs.io>`_


Now download the required files from Github:

.. code-block:: bash

  git clone https://github.com/pace-neutrons/horace-euphonic-interface.git


Then add the ``horace-euphonic-interface`` folder to the MATLAB search path.

.. code-block:: matlab

  >> addpath('/path/to/horace-euphonic-interface')

The Python executable that you installed Euphonic with also needs to be
specified in MATLAB. You can find the executable location in Python with:

.. code-block:: python

  >>> import sys
  >>> print(sys.executable)

You can then set this executable in MATLAB using:

.. code-block:: MATLAB

  >> pyversion('/path/to/python')

.. note::

  **Running on Linux**

  If running on Linux, the following must also be set from MATLAB to avoid
  clashes between Python/MATLAB mathematics libraries:

  .. code-block:: MATLAB

    >> py.sys.setdlopenflags(int32(10));

  This must be done **before** Python has been loaded in MATLAB (use
  ``pyversion`` to see if Python is already loaded). The only way to unload
  Python once it has been loaded is to restart MATLAB

Now that the MATLAB path and pyversion have been set up, test the installation
in MATLAB using:

.. code-block:: matlab

  >> euphonic_on

If there are no warnings everything should be installed correctly.

The above commands can be added to a
`startup.m <https://www.mathworks.com/help/matlab/ref/startup.html>`_ file so
they are executed automatically at the start of every MATLAB session

IDAaaS Installation
-------------------

Euphonic is already installed in a Python virtual environment at
``/usr/local/virtualenvs/euphonicenv`` and ``horace-euphonic-interface``
is available at ``/usr/local/mprogs``. To make use of these, add the following to
your ``startup.m``:

.. code-block:: matlab

  addpath('/usr/local/mprogs/horace-euphonic-interface')
  pyversion '/usr/local/virtualenvs/euphonicenv/bin/python3'
  py.sys.setdlopenflags(int32(10))
  euphonic_on

That's it!

Usage
-----

In Horace, the ``disp2sqw_eval`` simulation function is used to simulate
experimental data with Euphonic - this requires a function handle, to use
Euphonic this is ``euphonic_sf``. For information on ``euphonic_sf``
parameters, type:

.. code-block:: matlab

  >> help euphonic_sf

Many of the parameters are passed straight to Euphonic, so see the Euphonic
docs for more details.

An example script simulating a simple cut is below:

.. code-block:: matlab

  % Read in experimental cut
  cut = read_horace('quartz.d2d');

  % Set required parameters
  fwhh = 4.0;
  temperature = 5;
  scale = 1.0;
  par = [temperature, scale];
  scattering_lengths = struct('Si', 4.1491, 'O', 5.803);

  % Set extra parameters
  opts = {'model_args', {'quartz.castep_bin'}, ...
          'phonon_kwargs', {'asr', 'reciprocal', 'reduce_qpts', true, ...
                            'use_c', true, 'n_threads', int32(2), ...
                            'eta_scale', 0.75}, ...
          'dw_grid', [6,6,6], ...
          'conversion_mat', [1,0,0; 0,1,0; 0,0,-1], 
          'negative_e', true, ...
          'chunk', 5000, ...
          'lim', 1e-7};

  % Finally simulate
  cut_sim = disp2sqw_eval( ...
      cut, @euphonic_sf, {par, scattering_lengths, opts}, fwhh, 'all');

  % Plot
  plot(cut_sim);

.. note::

  **conversion_mat**

  Pay particular attention to this parameter, this is a 3x3 matrix to convert
  from the q-points in Horace to the q-points in the modelling code. This will
  be required if you've used a different unit cell convention/orientation in
  Horace and your modelling code, and will depend on the cells chosen. If
  set incorrectly, the results will not make sense (or worse, may happen to
  make sense at first in certain cuts due to symmetry, but give incorrect
  results in other cuts later on!)

.. toctree::
   :hidden:
   :maxdepth: 2

   release-notes
