import numpy as np
import os
from euphonic import Crystal, ForceConstants, QpointPhononModes, DebyeWaller, ureg
from euphonic.util import mp_grid

class euphonic_wrapper(object):
    # This a wrapper around the Euphonic ForceConstants and QpointPhononModes classes to make it easier to access from Matlab
    # It is meant to be used with a Matlab python_wrapper class and implements a horace_sqw function for use with Horace

    def __init__(self, value=None, **kwargs):
        self.force_constants = None
        self.phonon_modes = None
        self.debye_waller = None
        self.debye_waller_grid = None
        self.temperature = 0.0 * ureg('K')
        self.bose = True
        self.negative_e = False
        self.conversion_mat = None
        self.chunk = 5000
        self.lim = np.inf
        self.scattering_lengths = 'Sears1992'
        self.weights = None
        self.asr = None
        self.dipole = True
        self.eta_scale = 1.0
        self.splitting = True
        self.insert_gamma = False
        self.reduce_qpts = True
        self.use_c = False
        self.n_threads = 1
        self.fall_back_on_python = True
        
        if value is not None:
            if isinstance(value, str):
                self.load(value)
            elif hasattr('calculate_qpoint_phonon_modes'):
                self.force_constants = value
            elif hasattr('calculate_structure_factor'):
                self.phonon_modes = value
            elif isinstance(value, dict):
                kwargs.update(value)

        # Simple parameters can be set in keyword arguments
        if len(kwargs.keys()) > 0:
            for ky in ['debye_waller_grid', 'bose', 'negative_e', 'conversion_mat', 'chunk', 'lim', 'weights', 'asr',
                       'dipole', 'eta_scale', 'splitting', 'insert_gamma', 'reduce_qpts', 'use_c', 'n_threads',
                       'fall_back_on_python', 'temperature']:
                if ky in kwargs:
                    setattr(self, ky, kwargs.pop(ky))

        # If there are still keyword arguments they should relate to constructing ForceConstants or QpointPhononModes
        if len(kwargs.keys()) > 0:
            if 'path' in kwargs:
                try:
                    self.force_constants = self.from_phonopy(kwargs)
                except:
                    self.from_dict(kwargs)
            else:
                self.from_dict(kwargs)
                
    def load(self, value):
        # Tries to automatically determine type of input and auto-load it
        if os.path.isdir(value):
            self.force_constants = ForceConstants.from_phonopy(path=value)
        elif os.path.isfile(value):
            with open(value, 'rb') as fil:
                byt = fil.read(14)
            if byt == b'\x00\x00\x00\nCASTEP_BIN':
                self.force_constants = ForceConstants.from_castep(value)
            elif byt[:9] == b'phonopy:\n':
                self.force_constants = ForceConstants.from_phonopy(path=os.path.dirname(value), summary_name=value)
            elif byt[:8] == b'\x89HDF\r\n\x1a\n':
                # Assumes that the summary is in the 'phonopy.yaml' file
                self.force_constants = ForceConstants.from_phonopy(path=os.path.dirname(value), fc_name=value)
            elif byt[:2] == b'{\n':
                self.force_constants = ForceConstants.from_json_file(value)
            elif byt == b' BEGIN header\n':
                self.phonon_modes = QpointPhononModes.from_castep(value)
            else:
                raise RuntimeError(f'Cannot read {filename} due to unknown format')
        else:
            raise RuntimeError('Input string must be a file or folder name')

    def from_dict(self, val):
        # Constructs object manually from a dictionary of values
        if 'crystal' not in val:
            val['crystal'] = Crystal.from_dict(val).to_dict()
        try:
            self.force_constants = ForceConstants.from_dict(val)
        except AttributeError:
            try:
                self.phonon_modes = QpointPhononModes.from_dict(val)
            except AttributeError:
                raise RuntimeError('Cannot construct either a force constants model or set of phonon modes from input')

    def from_phonopy(self, val):
        try:
            arg_dict = {'path': val.pop('path', '.'), 
                        'summary_name': val.pop('summary_name', 'phonopy.yaml'),
                        'born_name': val.pop('born_name', None),
                        'fc_name': val.pop('fc_name', 'FORCE_CONSTANTS'),
                        'fc_format': val.pop('fc_format', None)}
            self.force_constants = ForceConstants.from_phonopy(**arg_dict)
        except:
            arg_dict = {'path': val.pop('path', '.'), 
                        'summary_name': val.pop('summary_name', 'phonopy.yaml'),
                        'phonon_name': val.pop('phonon_name', 'band.yaml'),
                        'phonon_format': val.pop('phonon_format', None)}
            self.phonon_modes = QpointPhononModes.from_phonopy(**arg_dict)
 
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
