function [w, sf] = euphonic_sf (qh, qk, ql, pars, seedname, scattering_lengths, opts)
% Calls Python package Euphonic to calculate the neutron scattering intensity
% for each branch at each specified q-point. Euphonic reads an output from a
% modelling code which contains the force constants matrix (e.g. a .castep_bin
% file) and interpolates to find the eigenvalues and eigenvectors at the requested
% q-points. It then calculates the scattering intensity at each q-point using the
% one-phonon scattering function (10.23, Pg 226, Dove Structure and Dynamics)
%
%   >> [w, sf] = calculate_sf(qh, qk, ql, par)
%
% Input:
% ------
%   qh,qk,ql           Arrays of h,k,l
%   par                Parameters [T scale]
%                          T                     Temperature (for Bose factor)
%                          scale                 Overall scale factor
%   model              String containing modelling software that you want to run. Valid values:
%                          * 'CASTEP'
%   seedname           String containing seedname e.g. If using CASTEP and seedname = 'ZnO', the 'ZnO.castep_bin' file will be read
%   scattering_lengths Structure containing scattering lengths for each ion type in fm e.g. , struct('O', 5.803)
%
%   opts               Other arguments
%                          model                 String defining the atomistic modelling code. Default: 'CASTEP'
%                              * 'CASTEP'
%                          conversion_mat        3 x 3 matrix for converting hkl in the lattice used in Horace
%                                                to hkl in the lattice used in the simulation code
%                          dw_grid               Length 3 vector specifying the grid on which to calculate the
%                                                Debye-Waller factor e.g. [6, 6, 6] If dw_grid is not supplied,
%                                                the Debye-Waller factor will not be calculated
%                          dipole                Whether to apply the dipole tail correction to the dynamical
%                                                matrix. Default: true
%                          splitting             Whether to calculate the LO-TO splitting at the gamma points.
%                                                Default: true
%                          asr                   String specifying which form of the acoustic sum rule to apply.
%                                                By default no acoustic sum rule is applied. Valid values:
%                              * 'realspace'     Applies the sum rule to the real space force constants matrix
%                              * 'reciprocal'    Applies the sum rule to the dynamical matrix at each q
%                                                Default: None
%                          eta_scale             Float that changes the cutoff in real/reciprocal space for the
%                                                dipole Ewald sum. A higher value uses more reciprocal terms.
%                                                This can be tuned for optimal performance
%                                                Default: 1.0
%                          nprocs                Number of processes to use when calculating phonons with Python
%                                                multiprocessing
%                                                Default: 1
%                          clear                 Whether to clear persistent data and reread .castep_bin file and do all
%                                                calculations from scratch. Otherwise the data read from .castep_bin
%                                                is saved for reuse to avoid repeating one time calculations
%                                                (e.g. Acoustic sum rule correction)
%                                                Default: false
%                          chunk                 How many q-points at a time to send to Euphonic, used to avoid potential
%                                                memory errors and feedback on progress
%                                                Default: 1000
%                          lim                    Upper limit on the per-branch structure factors. Used to avoid smearing
%                                                of high intensity Bragg peaks when using Gaussian broadening
%                                                Default: inf
% Output:
% -------
%   w                  Array of energies for the dispersion
%   sf                 Array of spectral weights
%
%

    persistent data;

    T = pars(1);
    scale = pars(2);

    % Set default options
    ops = struct('model', 'CASTEP', ...
                 'conversion_mat', string(missing), ...
                 'dw_grid', string(missing), ...
                 'dipole', true, ...
                 'splitting', true, ...
                 'asr', string(missing), ...
                 'eta_scale', 1.0, ...
                 'nprocs', uint8(1), ...
                 'clear', false, ...
                 'chunk', 1000, ...
                 'lim', inf);
    op_names = fieldnames(ops);
    
    n_args = length(opts);
    if round(n_args/2)~=n_args/2
        error('euphonic_sf needs name/value pairs')
    end

    % Set options
    for pair = reshape(opts,2,[])
        name = lower(pair{1}); % make case insensitive
        if strcmp(name, 'dw_grid') || strcmp(name, 'nprocs')
            ops.(name) = uint8(pair{2});
        elseif strcmp(name, 'conversion_mat')
            ops.(name) = reshape(pair{2}, 1, 9);
        % Set other options
        elseif any(strcmp(name,op_names))
            ops.(name) = pair{2};
        else
            error('%s is not a recognized parameter name',name);
        end
    end

    if ops.clear
        data = [];
    end

    qh_py = reshape(qh, 1, numel(qh));
    qk_py = reshape(qk, 1, numel(qk));
    ql_py = reshape(ql, 1, numel(ql));
    n_qpts = length(qh);
    w_mat = [];
    sf_mat = [];
    % Calculate in chunks to avoid memory errors
    for i=1:ceil(n_qpts/ops.chunk)
        qi = (i-1)*ops.chunk + 1;
        qf = min(i*ops.chunk, n_qpts);
        n = qf - qi + 1;
        fprintf('Using Euphonic to interpolate for q-points %d:%d out of %d\n', qi, qf, n_qpts)
        if ~isempty(data) && data.seedname == seedname
            output = py.euphonic_sf.calculate_sf_cont(data, qh_py(:,qi:qf), qk_py(:,qi:qf), ql_py(:,qi:qf), ...
                scattering_lengths, ops.dw_grid, ops.conversion_mat, T, scale, ops.asr, ops.dipole, ...
                ops.splitting, ops.eta_scale, ops.nprocs);
        else
            output = py.euphonic_sf.calculate_sf(seedname, qh_py(:,qi:qf), qk_py(:,qi:qf), ql_py(:,qi:qf), ...
                scattering_lengths, ops.dw_grid, ops.conversion_mat, T, scale, ops.asr, ops.dipole, ...
                ops.splitting, ops.eta_scale, ops.nprocs);
            data = output{"data"};
        end
        w_mat = vertcat(w_mat, ...
                        reshape(double(py.array.array('d',py.numpy.nditer(output{"w"}))), output{"w"}.size/n, n)');
        sf_mat = vertcat(sf_mat, ...
                         reshape(double(py.array.array('d',py.numpy.nditer(output{"sf"}))), output{"sf"}.size/n, n)');
    end

    % Limit max structure factor value
    sf_mat = min(sf_mat, ops.lim);

    w = num2cell(w_mat, 1);
    sf = num2cell(sf_mat, 1);

end
