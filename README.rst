=========================
horace-euphonic-interface
=========================

See the `docs <https://horace-euphonic-interface.readthedocs.io/en/latest/>`_.

For developers
==============

Test data
---------

Test data is in Matlab ``.mat`` format and generated here 
but is *stored in the ``euphonic_sqw_models`` repository*.

In case the code changes so as to invalidate the test data, you can 
generate it using ``runtests('test/EuphonicGenerateTestData.m')`` here.
Then copy the ``*.mat`` files in ``test/expected_output`` to the
``euphonic_sqw_models`` repository and commit it.

Since we include ``euphonic_sqw_models`` as a submodule here, it will then
include the test data which must be the same in both repository.

Euphonic minimum version
------------------------

The minimum require version of Euphonic is stored in the 
``min_requirements.txt`` file of ``euphonic_sqw_models`` (not here).
Like the test data, this is inherited by this repo as a submodule
and propagated further.
