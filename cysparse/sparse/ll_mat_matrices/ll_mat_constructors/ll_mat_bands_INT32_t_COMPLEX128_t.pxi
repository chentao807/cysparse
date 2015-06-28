

cdef LLSparseMatrix_INT32_t_COMPLEX128_t MakeBandLLSparseMatrix_INT32_t_COMPLEX128_t(LLSparseMatrix_INT32_t_COMPLEX128_t A, list diag_coeff, list numpy_arrays):
    """
    Populate an ``LLSparseMatrix_INT32_t_COMPLEX128_t with diagonals.

    See https://en.wikipedia.org/wiki/Band_matrix.

    Note:
        We don't expect the matrix to be square.
    """
    cdef:
        INT32_t i, j, A_nrow, A_ncol

    A_nrow, A_ncol = A.shape

    # NON OPTIMIZED code
    for i from 0 <= i < A_nrow:
        A.put(i, 0, element)
        for j from 0 <= j < A_ncol:
            A.put(0, j, element)
            if i == j:
                A.put(i, j, element)

    return A