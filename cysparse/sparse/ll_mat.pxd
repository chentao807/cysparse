"""
Main entry to create ``LLSparseMatrix`` matrices.

Basically, we define all factory methods to create ``LLSparseMatrix`` objects.

Warning:
    ``LLSparseMatrix`` matrices can **only** be constructed through a *factory* function, **not** by direct
    instantiation.
"""

from cysparse.common_types.cysparse_types cimport *

#from cysparse.sparse.ll_mat_view cimport LLSparseMatrixView

cdef FLOAT32_t LL_MAT_INCREASE_FACTOR

cdef INT32_t LL_MAT_DEFAULT_SIZE_HINT

cdef INT32_t LL_MAT_PPRINT_COL_THRESH
cdef INT32_t LL_MAT_PPRINT_ROW_THRESH

