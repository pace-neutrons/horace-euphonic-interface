# euphonic_calc.py
import numpy as np
from euphonic.data.interpolation import InterpolationData
from euphonic import ureg


def calculate_sf_cont(data, qh, qk, ql, scattering_lengths, dw_grid,
                      conv_matrix, T, scale, asr, dipole, splitting,
                      eta_scale, nprocs):
    qpts = np.column_stack((qh, qk, ql))
    if conv_matrix:
        conv_matrix = np.reshape(conv_matrix, (3, 3))
        qpts = np.einsum('ij,jk->ik', qpts, conv_matrix)
    if nprocs > 1:
        freqs, _ = data.calculate_fine_phonons(
            qpts, asr=asr, dipole=dipole, eta_scale=eta_scale, nprocs=nprocs)
    else:
        freqs, _ = data.calculate_fine_phonons(
            qpts, asr=asr, dipole=dipole, eta_scale=eta_scale)
    sf = data.calculate_structure_factor(
        scattering_lengths, dw_grid=dw_grid, T=T, scale=scale)
    out = {"sf": sf,
           "w": freqs.to('meV').magnitude}
    return out


def calculate_sf(seedname, qh, qk, ql, scattering_lengths, dw_grid,
                 conv_matrix, T, scale, asr, dipole, splitting, eta_scale,
                 nprocs):
    data = InterpolationData(seedname)
    qpts = np.column_stack((qh, qk, ql))
    if conv_matrix:
        conv_matrix = np.reshape(conv_matrix, (3, 3))
        qpts = np.einsum('ij,jk->ik', qpts, conv_matrix)
    if nprocs > 1:
        freqs, _ = data.calculate_fine_phonons(
            qpts, asr=asr, dipole=dipole, eta_scale=eta_scale, nprocs=nprocs)
    else:
        freqs, _ = data.calculate_fine_phonons(
            qpts, asr=asr, dipole=dipole, eta_scale=eta_scale)
    sf = data.calculate_structure_factor(
        scattering_lengths, dw_grid=dw_grid, T=T, scale=scale)
    out = {"sf": sf,
           "w": freqs.to('meV').magnitude,
           "data": data}
    return out


if __name__ == '__main__':
    main()
