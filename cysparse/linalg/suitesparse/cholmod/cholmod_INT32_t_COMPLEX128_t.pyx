

cdef class CholmodContext_INT32_t_COMPLEX128_t:
    """
    Cholmod Context from SuiteSparse.

    This version **only** deals with ``LLSparseMatrix_INT32_t_COMPLEX128_t`` objects.

    We follow the common use of Cholmod. In particular, we use the same names for the methods of this
    class as their corresponding counter-parts in Cholmod.
    """


    def __cinit__(self, LLSparseMatrix_INT32_t_COMPLEX128_t A):
        """
        """
        pass