"""
Several routines to multiply a :class:`CSRSparseMatrix` matrix with a (comming from a :program:`NumPy` vector) C-array.

Covered cases:

1. :math:`A * b`:

- :program:`NumPy` array data C-contiguous, ``CSRSparseMatrix`` not symmetric
- :program:`NumPy` array data C-contiguous, ``CSRSparseMatrix`` symmetric
- :program:`NumPy` array data not C-contiguous, ``CSRSparseMatrix`` not symmetric
- :program:`NumPy` array data not C-contiguous, ``CSRSparseMatrix`` symmetric

2. :math:`A^t * b`

- :program:`NumPy` array data C-contiguous, ``CSRSparseMatrix`` not symmetric
- :program:`NumPy` array data not C-contiguous, ``CSRSparseMatrix`` not symmetric

3. :math:`A^h * b`

- :program:`NumPy` array data C-contiguous, ``CSRSparseMatrix`` not symmetric
- :program:`NumPy` array data C-contiguous, ``CSRSparseMatrix`` symmetric
- :program:`NumPy` array data not C-contiguous, ``CSRSparseMatrix`` not symmetric
- :program:`NumPy` array data not C-contiguous, ``CSRSparseMatrix`` symmetric

4. :math:`\textrm{conj}(A) * b`

- :program:`NumPy` array data C-contiguous, ``CSRSparseMatrix`` not symmetric
- :program:`NumPy` array data C-contiguous, ``CSRSparseMatrix`` symmetric
- :program:`NumPy` array data not C-contiguous, ``CSRSparseMatrix`` not symmetric
- :program:`NumPy` array data not C-contiguous, ``CSRSparseMatrix`` symmetric

Note:
    We only consider C-arrays with same type of elements as the type of elements in the ``CSRSparseMatrix``.
    Even if we construct the resulting :program:`NumPy` array as C-contiguous, the functions are more general and could
    be used with a given strided :program:`NumPy` `y` vector.
"""

########################################################################################################################
# A * b
########################################################################################################################

###########################################
# C-contiguous, non symmetric
###########################################
cdef void multiply_csr_mat_with_numpy_vector_kernel_INT32_t_INT64_t(INT32_t m, INT64_t *x, INT64_t *y,
         INT64_t *val, INT32_t *col, INT32_t *ind):
    """
    Compute ``y = A * x``.

    ``A`` is a :class:`CSRSparseMatrix` and ``x`` and ``y`` are one dimensional numpy arrays.
    In this kernel function, we only use the corresponding C-arrays.

    Warning:
        This version consider the arrays as C-contiguous (**without** strides).

    Args:
        m: Number of rows of the matrix ``A``.
        n: Number of columns of the matrix ``A``.
        x: C-contiguous C-array corresponding to vector ``x``.
        y: C-contiguous C-array corresponding to vector ``y``.
        val: C-contiguous C-array corresponding to vector ``A.val``.
        col: C-contiguous C-array corresponding to vector ``A.col``.
        ind: C-contiguous C-array corresponding to vector ``A.ind``.
    """
    cdef:
        INT64_t s
        INT32_t i, j, k

    for i from 0 <= i < m:

        s = <INT64_t>0.0

        for k from ind[i] <= k < ind[i+1]:
            s += val[k] * x[col[k]]

        y[i] = s


###########################################
# C-contiguous, symmetric
###########################################
cdef void multiply_sym_csr_mat_with_numpy_vector_kernel_INT32_t_INT64_t(INT32_t m, INT64_t *x, INT64_t *y,
             INT64_t *val, INT32_t *col, INT32_t *ind):
    """
    Compute ``y = A * x``.

    ``A`` is a **symmetric** :class:`CSRSparseMatrix` and ``x`` and ``y`` are one dimensional numpy arrays.
    In this kernel function, we only use the corresponding C-arrays.

    Warning:
        This version consider the arrays as C-contiguous (**without** strides).

    Args:
        m: Number of rows of the matrix ``A``.
        x: C-contiguous C-array corresponding to vector ``x``.
        y: C-contiguous C-array corresponding to vector ``y``.
        val: C-contiguous C-array corresponding to vector ``A.val``.
        col: C-contiguous C-array corresponding to vector ``A.col``.
        ind: C-contiguous C-array corresponding to vector ``A.ind``.
    """
    cdef:
        INT32_t i, j, k

    # init numpy array
    for i from 0 <= i < m:

        y[i] = <INT64_t>0.0


    for i from 0 <= i < m:
        for k from ind[i] <= k < ind[i+1]:
            j = col[k]
            y[i] += val[k] * x[j]
            if i != j:
                y[j] += val[k] * x[i]

###########################################
# Non C-contiguous, non symmetric
###########################################
cdef void multiply_csr_mat_with_strided_numpy_vector_kernel_INT32_t_INT64_t(INT32_t m,
            INT64_t *x, INT32_t incx,
            INT64_t *y, INT32_t incy,
            INT64_t *val, INT32_t *col, INT32_t *ind):
    """
    Compute ``y = A * x``.

    ``A`` is :class:`CSRSparseMatrix` and ``x`` and ``y`` are one dimensional **non** C-contiguous numpy arrays.
    In this kernel function, we only use the corresponding C-arrays.

    Warning:
        This version consider *both* numpy arrays as **non** C-contiguous (**with** strides).

    Args:
        m: Number of rows of the matrix ``A``.
        x: (non necessarily C-contiguous) C-array corresponding to vector ``x``.
        incx: Stride for array ``x``.
        y: (non necessarily C-contiguous) C-array corresponding to vector ``y``.
        incy: Stride for array ``y``.
        val: C-contiguous C-array corresponding to vector ``A.val``.
        col: C-contiguous C-array corresponding to vector ``A.col``.
        ind: C-contiguous C-array corresponding to vector ``A.ind``.
    """
    cdef:
        INT64_t s
        INT32_t i, j, k

    for i from 0 <= i < m:

        s = <INT64_t>0.0

        for k from ind[i] <= k < ind[i+1]:
            s += val[k] * x[col[k] * incx]

        y[i* incy] = s


###########################################
# Non C-contiguous, symmetric
###########################################
cdef void multiply_sym_csr_mat_with_strided_numpy_vector_kernel_INT32_t_INT64_t(INT32_t m,
                INT64_t *x, INT32_t incx,
                INT64_t *y, INT32_t incy,
                INT64_t *val, INT32_t *col, INT32_t *ind):
    """
    Compute ``y = A * x``.

    ``A`` is a **symmetric** :class:`CSRSparseMatrix` and ``x`` and ``y`` are one dimensional **non** C-contiguous numpy arrays.
    In this kernel function, we only use the corresponding C-arrays.

    Warning:
        This version consider *both* numpy arrays as **non** C-contiguous (**with** strides).

    Args:
        m: Number of rows of the matrix ``A``.
        x: (non necessarily C-contiguous) C-array corresponding to vector ``x``.
        incx: Stride for array ``x``.
        y: (non necessarily C-contiguous) C-array corresponding to vector ``y``.
        incy: Stride for array ``y``.
        val: C-contiguous C-array corresponding to vector ``A.val``.
        col: C-contiguous C-array corresponding to vector ``A.col``.
        ind: C-contiguous C-array corresponding to vector ``A.ind``.
    """
    cdef:
        INT32_t i, j, k

    # init numpy array
    for i from 0 <= i < m:

        y[i] = <INT64_t>0.0


    for i from 0 <= i < m:
        for k from ind[i] <= k < ind[i+1]:
            j = col[k]
            y[i * incy] += val[k] * x[j * incx]
            if i != j:
                y[j * incy] += val[k] * x[i * incx]

########################################################################################################################
# A^t * b
########################################################################################################################

###########################################
# C-contiguous, non symmetric
###########################################
cdef void multiply_tranposed_csr_mat_with_numpy_vector_kernel_INT32_t_INT64_t(INT32_t m, INT32_t n, INT64_t *x, INT64_t *y,
         INT64_t *val, INT32_t *col, INT32_t *ind):
    """
    Compute :math:`y = A^t * x`.

    ``A`` is a :class:`LLSparseMatrix` and ``x`` and ``y`` are one dimensional numpy arrays.
    In this kernel function, we only use the corresponding C-arrays.

    Warning:
        This version consider the arrays as C-contiguous (**without** strides).

    Args:
        m: Number of rows of the matrix ``A``.
        n: Number of columns of the matrix ``A``.
        x: C-contiguous C-array corresponding to vector ``x``.
        y: C-contiguous C-array corresponding to vector ``y``.
        val: C-contiguous C-array corresponding to vector ``A.val``.
        col: C-contiguous C-array corresponding to vector ``A.col``.
        ind: C-contiguous C-array corresponding to vector ``A.ind``.
    """
    cdef:
        INT32_t i, j, k

    # init numpy array
    for j from 0 <= j < n:

        y[j] = <INT64_t>0.0



    for i from 0 <= i < m:
        for k from ind[i]<= k < ind[i+1]:
            y[col[k]] += val[k] * x[i]



###########################################
# Non C-contiguous, non symmetric
###########################################
cdef void multiply_tranposed_csr_mat_with_strided_numpy_vector_kernel_INT32_t_INT64_t(INT32_t m, INT32_t n, INT64_t *x, INT32_t incx, INT64_t *y, INT32_t incy,
         INT64_t *val, INT32_t *col, INT32_t *ind):
    """
    Compute :math:`y = A^t * x`.

    ``A`` is a :class:`CSRSparseMatrix` and ``x`` and ``y`` are one dimensional numpy arrays.
    In this kernel function, we only use the corresponding C-arrays.

    Warning:
        This version consider the arrays as C-contiguous (**without** strides).

    Args:
        m: Number of rows of the matrix ``A``.
        n: Number of columns of the matrix ``A``.
        x: (non necessarily C-contiguous) C-array corresponding to vector ``x``.
        incx: Stride for array ``x``.
        y: (non necessarily C-contiguous) C-array corresponding to vector ``y``.
        incy: Stride for array ``y``.
        val: C-contiguous C-array corresponding to vector ``A.val``.
        col: C-contiguous C-array corresponding to vector ``A.col``.
        ind: C-contiguous C-array corresponding to vector ``A.ind``.
    """
    cdef:
        INT32_t i, j, k

    # init numpy array
    for j from 0 <= j < n:

        y[j] = <INT64_t>0.0



    for i from 0 <= i < m:
        for k from ind[i]<= k < ind[i+1]:
            y[col[k] * incy] += val[k] * x[i * incx]

