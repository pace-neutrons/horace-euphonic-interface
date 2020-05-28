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
%     model_args     Structure containing ForceConstants.from_model
%                    positional arguments. e.g if model is 'CASTEP', these
%                    are the ForceConstants.from_castep arguments.
%                    Default: empty structure
%     model_kwargs   Same as above, but for keyword arguments. Default:
%                    empty structure
%     conversion_mat 3 x 3 matrix for converting hkl in the lattice used in
%                    Horace to hkl in the lattice used in the simulation code
% Output:
% -------
%   w                  Array of energies for the dispersion
%   sf                 Array of spectral weights
%
%
T = pars(1);
scale = pars(2);

n_args = length(opts);
if round(n_args/2)~=n_args/2
    error('euphonic_sf needs name/value pairs')
end
opts = reshape(opts,2,[]);
opts_map = containers.Map(opts(1, :), opts(2, :));

% Read force constants
eu = py.importlib.import_module('euphonic')
if opts_map('model') == "CASTEP"
    model_args = opts_map('model_args');
    fc = eu.ForceConstants.from_castep(model_args{1});
end

% Convert q-points and calculate frequencies/eigenvectors
qpts = horzcat(qh, qk, ql);
if isKey(opts_map, 'conversion_mat')
    conv_mat = opts_map('conversion_mat');
    qpts = qpts*conv_mat;
end
qpts_py = py.numpy.reshape(py.numpy.array(qpts(:).'), ...
                           int32([length(qh), 3]), 'F');
phonons = fc.calculate_qpoint_phonon_modes(qpts_py);

% Convert scattering lengths and calculate structure factor
ureg = eu.ureg;
atom_types = fieldnames(scattering_lengths);
for i = 1:length(atom_types)
    scattering_lengths.(atom_types{i}) = ...
        scattering_lengths.(atom_types{i})*ureg('fm');
end
sf_obj = phonons.calculate_structure_factor(scattering_lengths);
w_py = sf_obj.frequencies.magnitude;
sf_py = sf_obj.structure_factors.magnitude;

w = num2cell(reshape(double(w_py), w_py.shape{1}, w_py.shape{2}), 1);
sf = num2cell(reshape(double(sf_py), sf_py.shape{1}, sf_py.shape{2}), 1);
end
