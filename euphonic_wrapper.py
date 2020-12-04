import numpy as np
import os
from euphonic import Crystal, ForceConstants, QpointPhononModes, DebyeWaller, ureg
from euphonic.util import mp_grid

class EuphonicWrapper(object):
    # This a wrapper around the Euphonic ForceConstants and QpointPhononModes classes to make it easier to access from Matlab
    # It is meant to be used with a Matlab python_wrapper class and implements a horace_sqw function for use with Horace

    defaults = {'force_constants': None, 'phonon_modes': None, 'debye_waller': None, 'debye_waller_grid': None, 
                'temperature': 0.0 * ureg('K'), 'bose': True, 'negative_e': False, 'conversion_mat': None, 'chunk': 5000, 
                'lim': np.inf, 'scattering_lengths': 'Sears1992', 'weights': None, 'asr': None, 'dipole': True, 
                'eta_scale': 1.0, 'splitting': True, 'insert_gamma': False, 'reduce_qpts': True, 'use_c': False, 
                'n_threads': 1, 'fall_back_on_python': True, 'convolution_function': 'gauss'}

    def __init__(self, value=None, **kwargs):
        for key, val in self.defaults.items():
            setattr(self, key, kwargs.pop(key, self.defaults[key]))

        if value is not None:
            if hasattr(value, 'calculate_qpoint_phonon_modes'):
                self.force_constants = value
            elif hasattr(value, 'calculate_structure_factor'):
                self.phonon_modes = value
            elif isinstance(value, dict):
                kwargs.update(value)

    def calculate_sf(self, qpts):
        if self.temperature > 0:
            if self.debye_waller is None and self.debye_waller_grid is not None:
                self.calculate_debye_waller()
        phonons = self.calculate_phonon_modes(qpts)
        sf_obj = phonons.calculate_structure_factor(scattering_lengths=self.scattering_lengths,
                                                    dw=self.debye_waller)
        w = sf_obj.frequencies.magnitude
        sf = sf_obj.structure_factors.magnitude
        if self.temperature > 0 and self.bose:
            bose = sf_obj._bose_factor(self.temperature)
            sf = (1 + bose) * sf
        if self.negative_e:
            w = np.hstack((w, -w))
            neg_sf = sf_obj.structure_factors.magnitude
            if self.temperature > 0 and self.bose:
                neg_sf = bose * neg_sf
            sf = np.hstack((sf, neg_sf))
        return w, sf
        
    def horace_sqw(self, qh, qk, ql, scale=1., *args, **kwargs):
        if self.chunk > 0:
            lqh = len(qh)
            for i in range(int(np.ceil(lqh / self.chunk))):
                qi = i * self.chunk
                qf = min((i+1) * self.chunk, lqh)
                n = qf - qi + 1
                print(f'Using Euphonic to interpolate for q-points {qi}:{qf} out of {lqh}')
                qpts = np.vstack((np.squeeze(qh[qi:qf]), np.squeeze(qk[qi:qf]), np.squeeze(ql[qi:qf]))).T
                sqw = self.calculate_sf(qpts)
                if i == 0:
                    w = sqw[0]
                    sf = sqw[1]
                else:
                    w = np.vstack((w, sqw[0]))
                    sf = np.vstack((sf, sqw[1]))
        else:
            w, sf = self.calculate_sf(np.vstack((np.squeeze(qh), np.squeeze(qk), np.squeeze(ql))).T)
        if scale != 1.:
            sf *= scale
        # Splits into different dispersion surfaces (python tuple == matlab cell)
        # But the data must be contiguous in memory so we need to do a real tranpose (.T just changes strides)
        # So we need to convert to "fortran" format (which physically transposes data) before doing ".T"
        w = np.asfortranarray(w).T
        sf = np.asfortranarray(sf).T
        return tuple(w), tuple(sf)

    def calculate_phonon_modes(self, qpts):
        if self.force_constants is None:
            raise RuntimeError('Force constants model not set')
        return self.force_constants.calculate_qpoint_phonon_modes(qpts,
            weights=self.weights, asr=self.asr, dipole=self.dipole, eta_scale=self.eta_scale,
            splitting=self.splitting, insert_gamma=self.insert_gamma, reduce_qpts=self.reduce_qpts,
            use_c=self.use_c, n_threads=self.n_threads, fall_back_on_python=self.fall_back_on_python)

    def calculate_debye_waller(self):
        if self.temperature <= 0.0:
            return
        if self.debye_waller_grid is None:
            raise RuntimeError('Q-points grid for Debye Waller calculation not set')
        dw_qpts = mp_grid(self.debye_waller_grid)
        dw_phonons = self.calculate_phonon_modes(dw_qpts)
        self.debye_waller = dw_phonons.calculate_debye_waller(self.temperature)

    @property
    def force_constants(self):
        return self._force_constants

    @force_constants.setter
    def force_constants(self, val):
        if val is None or val == 'None':  # Using string 'None' to make it easier for Matlab users
            self._force_constants = None
        else:
            if hasattr(val, 'calculate_qpoint_phonon_modes'):
                self._force_constants = val
            else:
                raise RuntimeError('Invalid force constant model')

    @property
    def phonon_modes(self):
        return self._phonon_modes

    @phonon_modes.setter
    def phonon_modes(self, val):
        if val is None or val == 'None':
            self._phonon_modes = None
        else:
            if hasattr(val, 'calculate_structure_factor'):
                self._phonon_modes = val
            else:
                raise RuntimeError('Invalid phonon modes object')

    @property
    def debye_waller(self):
        return self._debye_waller 

    @debye_waller.setter
    def debye_waller(self, val):
        if val is None or val == 'None':
            self._debye_waller = None
        else:
            if hasattr(val, 'debye_waller'):
                self._debye_waller = val
            else:
                raise RuntimeError('Invalid Debye-Waller object')

    @property
    def debye_waller_grid(self):
        return self._debye_waller_grid

    @debye_waller_grid.setter
    def debye_waller_grid(self, val):
        if val is None or val == 'None':
            self._debye_waller_grid = None
        else:
            val = np.squeeze(np.array(val))
            if np.shape(val) == (3, ):
                self._debye_waller_grid = [int(v) for v in val]
                # Reset the Debye Waller factor if it was previously set.
                self.debye_waller = None
            else:
                raise RuntimeError('Invalid Debye-Waller grid')

    @property
    def conversion_mat(self):
        return self._conversion_mat

    @conversion_mat.setter
    def conversion_mat(self, val):
        if val is None or val == 'None':
            self._conversion_mat = None
        else:
            val = np.array(val)
            if np.shape(val) == (3, 3):
                self._conversion_mat = val
            else:
                raise RuntimeError('Invalid conversion matrix')

    @property
    def temperature(self):
        return self._temperature

    @temperature.setter
    def temperature(self, val):
        self._temperature = val if hasattr(val, 'units') else (val * ureg('K'))

    @property
    def scattering_lengths(self):
        return self._scattering_lengths

    @scattering_lengths.setter
    def scattering_lengths(self, val):
        if isinstance(val, str):
            self._scattering_lengths = val
        elif isinstance(val, dict):
            self._scattering_lengths = \
                {ky: (v if hasattr(v, 'units') else v * ureg('fm')) for ky, v in val.items()}
        else:
            raise RuntimeError('Invalid scattering lengths')

    @property
    def chunk(self):
        return self._chunk

    @chunk.setter
    def chunk(self, val):
        self._chunk = int(val)
