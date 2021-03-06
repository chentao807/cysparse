"""
Several helper routines to test for symmetry of an  ``CSCSparseMatrix`` matrix.
"""

cdef bint is_symmetric_INT64_t_INT32_t(CSCSparseMatrix_INT64_t_INT32_t A):
    """
    Test if an arbitrary :class:``CSCSparseMatrix`` matrix is symmetric or not.

    """
    cdef:
        INT64_t i, j, k
        INT32_t v

    for j from 0 <= j < A.ncol:
        for k from A.ind[j] <= k < A.ind[j+1]:
            i = A.row[k]
            v = A.val[k]

            # test for symmetry
            if v != A[j, i]:
                return False

    return True