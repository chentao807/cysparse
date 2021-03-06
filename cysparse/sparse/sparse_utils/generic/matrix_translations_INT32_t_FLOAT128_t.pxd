#!python
#cython: boundscheck=False, wraparound=False, initializedcheck=False
    
"""
Diverse utilities to translate one matrix format into another.

"""
from cysparse.common_types.cysparse_types cimport *

cdef csr_to_csc_kernel_INT32_t_FLOAT128_t(INT32_t nrow, INT32_t ncol, INT32_t nnz,
                                      INT32_t * csr_ind, INT32_t * csr_col, FLOAT128_t * csr_val,
                                      INT32_t * csc_ind, INT32_t * csc_row, FLOAT128_t * csc_val)

cdef csc_to_csr_kernel_INT32_t_FLOAT128_t(INT32_t nrow, INT32_t ncol, INT32_t nnz,
                                      INT32_t * csc_ind, INT32_t * csc_row, FLOAT128_t * csc_val,
                                      INT32_t * csr_ind, INT32_t * csr_col, FLOAT128_t * csr_val)

cdef csr_to_ll_kernel_INT32_t_FLOAT128_t(INT32_t nrow, INT32_t ncol, INT32_t nnz,
                                      INT32_t * csr_ind, INT32_t * csr_col, FLOAT128_t * csr_val,
                                      INT32_t * ll_root, INT32_t * ll_col, INT32_t * ll_link, FLOAT128_t * ll_val)

cdef csc_to_ll_kernel_INT32_t_FLOAT128_t(INT32_t nrow, INT32_t ncol, INT32_t nnz,
                                      INT32_t * csc_ind, INT32_t * csc_row, FLOAT128_t * csc_val,
                                      INT32_t * ll_root, INT32_t * ll_col, INT32_t * ll_link, FLOAT128_t * ll_val)