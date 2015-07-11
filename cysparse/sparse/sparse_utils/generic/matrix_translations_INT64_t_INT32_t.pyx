from cysparse.types.cysparse_types cimport *


cdef csr_to_csc_kernel_INT64_t_INT32_t(INT64_t nrow, INT64_t ncol, INT64_t nnz,
                                      INT64_t * csr_ind, INT64_t * csr_col, INT32_t * csr_val,
                                      INT64_t * csc_ind, INT64_t * csc_row, INT32_t * csc_val):
    ############
    # compute csc_ind, i.e. the nnz of each column of the matrix
    ############
    cdef:
        INT64_t i, j, n

    # initialize to 0
    for j from 0 <= j <= ncol:
        csc_ind[j] = 0
    # count nnz per column
    for n from 0 <= n < nnz:
        csc_ind[csr_col[n]] += 1

    # cumsum the nnz per column to get csc_ind
    cdef:
        INT64_t cumsum = 0
        INT64_t temp = 0

    for j from 0<= j < ncol:
        temp  = csc_ind[j]
        csc_ind[j] = cumsum
        cumsum += temp

    csc_ind[ncol] = nnz

    # csc_ind is computed but will change in the next lines: we'll recompute it afterwoods

    ############
    # populate row and val
    ############
    cdef INT64_t jj, dest

    for i from 0 <= i < nrow:
        for jj from csr_ind[i] <= jj < csr_ind[i+1]:
            j  = csr_col[jj]
            dest = csc_ind[j]

            csc_row[dest] = i
            csc_val[dest] = csr_val[jj]

            csc_ind[j] += 1

    cdef INT64_t last = 0

    for j from 0 <= j <= ncol:
        temp   = csc_ind[j]
        csc_ind[j] = last
        last   = temp