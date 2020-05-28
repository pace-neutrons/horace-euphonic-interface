function [w, sf] = euphonic_sf (qh, qk, ql, pars, scattering_lengths, opts)
% Calls Python package Euphonic to calculate the neutron scattering intensity
% for each branch at each specified q-point. Euphonic reads an output from a
% modelling code which contains the force constants matrix (e.g. a .castep_bin
% file) and interpolates to find the eigenvalues and eigenvectors at the
% requested q-points. It then calculates the scattering intensity at each
% q-point using the one-phonon scattering function (10.23, Pg 226, Dove
% Structure and Dynamics)
%
%   >> [w, sf] = calculate_sf(qh, qk, ql, par)
%
% Input:
% ------
% qh,qk,ql           Arrays of h,k,l
% par                Parameters [T scale]
%                        T       Temperature (for Bose/Debye-Waller factors)
%                        scale   Overall scale factor
% scattering_lengths Structure containing scattering lengths for each ion type
%                    in fm e.g. struct('O', 5.803)
%
% opts               Other arguments
%                    ---------------
%     model          String defining the atomistic modelling code, one of
%                    ('CASTEP'). Default: 'CASTEP'
%     model_args     Cell array containing ForceConstants.from_model
%                    positional arguments. e.g if model is 'CASTEP', these
%                    are the ForceConstants.from_castep arguments.
%                    Default: empty cell array
%     model_kwargs   Same as above, but with key value pairs for keyword
%                    arguments. Default: empty cell array
%     phonon_kwargs  Cell array of key, value pairs that will be passed to
%                    ForceConstants.calculate_qpoint_phonon_modes as keyword
%                    arguments e.g. {'asr', 'reciprocal', 'use_c', true}
%                    Default: empty cell array
%     conversion_mat 3 x 3 matrix for converting hkl in the lattice used in
%                    Horace to hkl in the lattice used in the simulation code
%     chunk          How many q-points at a time to send to Euphonic, can be
%                    used to avoid potential memory errors and feedback on
%                    progress. Default: length(qh)
%     lim            Upper limit on the per-branch structure factors. Used to
%                    avoid smearing of high intensity Bragg peaks when using
%                    Gaussian broadening. Default: inf
% Output:
% -------
%   w                  Array of energies for the dispersion
%   sf                 Array of spectral weights
%
%
n_args = length(opts);
if round(n_args/2)~=n_args/2
    error('euphonic_sf needs name/value pairs')
end

T = pars(1);
scale = pars(2);

default_opts = {'model', 'CASTEP';
                'model_args', {};
                'model_kwargs', {};
                'phonon_kwargs', {};
                'chunk', length(qh),
                'lim', inf};
default_opts_map = containers.Map(default_opts(:, 1), default_opts(:, 2), ...
                                  'UniformValues', false);

n_args = length(opts);
if round(n_args/2)~=n_args/2
    error('euphonic_sf needs name/value pairs')
end
opts = reshape(opts,2,[]);
opts_map = containers.Map(opts(1, :), opts(2, :), 'UniformValues', false);
opts_map = [default_opts_map; opts_map];


eu = py.importlib.import_module('euphonic')
% Read force constants
if lower(opts_map('model')) == "castep"
    model_args = opts_map('model_args');
    fc = eu.ForceConstants.from_castep(model_args{1});
elseif lower(opts_map('model')) == "phonopy"
    model_kwargs = opts_map('model_kwargs');
    fc = eu.ForceConstants.from_phonopy(pyargs(model_kwargs{:}));
end

% Convert q-points
qpts = horzcat(qh, qk, ql);
if isKey(opts_map, 'conversion_mat')
    conv_mat = opts_map('conversion_mat');
    qpts = qpts*conv_mat;
end

% Convert scattering lengths to Pint Quantities
ureg = eu.ureg;
atom_types = fieldnames(scattering_lengths);
for i = 1:length(atom_types)
    scattering_lengths.(atom_types{i}) = ...
        scattering_lengths.(atom_types{i})*ureg('fm');
end

% Calculate frequencies/eigenvectors in chunks
w_mat = [];
sf_mat = [];
for i=1:ceil(length(qh)/opts_map('chunk'))
    qi = (i-1)*opts_map('chunk') + 1;
    qf = min(i*opts_map('chunk'), length(qh));
    n = qf - qi + 1;
    qpts_py = py.numpy.reshape( ...
        py.numpy.array(reshape(qpts(qi:qf, :), [], 1)), ...
        int32([n, 3]), 'F');

    fprintf('Using Euphonic to interpolate for q-points %d:%d out of %d\n', ...
            qi, qf, length(qh))
    phonon_kwargs = opts_map('phonon_kwargs');
    phonons = fc.calculate_qpoint_phonon_modes(qpts_py, pyargs(phonon_kwargs{:}));
    sf_obj = phonons.calculate_structure_factor(scattering_lengths);
    w_py = sf_obj.frequencies.magnitude;
    sf_py = sf_obj.structure_factors.magnitude;

    w_mat = vertcat(w_mat, reshape(double(w_py), w_py.shape{1}, w_py.shape{2}));
    sf_mat = vertcat(sf_mat, reshape(double(sf_py), sf_py.shape{1}, sf_py.shape{2}));
end
% Limit max structure factor value
sf_mat = min(sf_mat, opts_map('lim'));

w = num2cell(w_mat, 1);
sf = num2cell(sf_mat, 1);
end
