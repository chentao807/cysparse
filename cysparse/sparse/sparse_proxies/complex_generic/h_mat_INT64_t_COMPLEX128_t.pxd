#!python
#cython: boundscheck=False, wraparound=False, initializedcheck=False
    
"""
Syntactic sugar: we want to use the following code: ``A.H * b`` to compute :math:`A^h * b`.

``A.H`` returns a proxy to the original matrix ``A`` that allows us to use the above notation.
"""

from cysparse.common_types.cysparse_types cimport CPType
from cysparse.sparse.s_mat cimport SparseMatrix

cdef class ConjugateTransposedSparseMatrix_INT64_t_COMPLEX128_t:
    """
    Proxy to the conjugate transposed of a :class:`SparseMatrix`.

    Warning:
        This class is **not** a real matrix.
    """
    cdef:

        SparseMatrix A
