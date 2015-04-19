"""
Condensed Sparse Row (CSR) Format Matrices.


"""

from __future__ import print_function

from sparse_lib.sparse.sparse_mat cimport ImmutableSparseMatrix

from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free

cdef int CSR_MAT_PPRINT_ROW_THRESH = 500       # row threshold for choosing print format
cdef int CSR_MAT_PPRINT_COL_THRESH = 20        # column threshold for choosing print format


cdef _sort(int * a, int start, int end):
    """
    Sort array a between start and end - 1 (i.e. end **not** included).


    """
    # TODO: put this is a new file and test
    cdef int i, j, value;

    print ("start= %d, end = %d" % (start, end))
    i = start

    while i < end:

        value = a[i]
        j = i - 1
        while j >= start and a[j] > value:
            # shift
            a[j+1] = a[j]

            j -= 1

        # place key at right place
        a[j+1] = value

        i += 1


cdef class CSRSparseMatrix(ImmutableSparseMatrix):
    """
    Compressed Sparse Row Format matrix.

    Note:
        This matrix can **not** be modified.

    """
    ####################################################################################################################
    # Init/Free
    ####################################################################################################################
    def __cinit__(self, int nrow, int ncol, int nnz):
        self.__status_ok = False

    def __dealloc__(self):
        PyMem_Free(self.val)
        PyMem_Free(self.col)
        PyMem_Free(self.ind)

    ####################################################################################################################
    # Control
    ####################################################################################################################
    def is_well_constructed(self):
        """
        Tell if object is well constructed, i.e. if it was instantiated by a factory method.

        This method **doesn't** test if the matrix is coherent, only if its memory was properly initialized with a
        factory method.

        Returns:
            ``(status, error_msg)``:

        """
        error_msg = None
        well_constructed_ok = True

        if not self.__status_ok:
            error_msg = "CSRSparseMatrix must be instantiated by a factory method!"
            well_constructed_ok = self.__status_ok

        return well_constructed_ok, error_msg

    def raise_error_if_not_well_constructed(self):
        """
        Raises an error if method :meth:`is_well_constructed()` doesn't return ``True``.

        See:
            :meth:`is_well_constructed`.

        Raises:
            NotImplementedError: If the private attribute ``__status_ok`` is not ``True``.
        """
        status_ok, error_msg = self.is_well_constructed()

        if not status_ok:
            raise NotImplementedError(error_msg)

    ####################################################################################################################
    # Column indices ordering
    ####################################################################################################################
    def are_column_indices_sorted(self):
        """
        Tell if column indices are sorted in augmenting order.


        """
        cdef int i
        cdef int col_index
        cdef int col_index_stop

        if self.__col_indices_sorted_test_done:
            return self.__col_indices_sorted
        else:
            # do the test
            self.__col_indices_sorted_test_done = True
            # test each row
            for i from 0 <= i < self.nrow:
                col_index = self.ind[i]
                col_index_stop = self.ind[i+1] - 1

                self.__first_row_not_ordered = i

                while col_index < col_index_stop:
                    if self.col[col_index] > self.col[col_index + 1]:
                        self.__col_indices_sorted = False
                        return self.__col_indices_sorted
                    col_index += 1

        self.__first_row_not_ordered = self.nrow
        self.__col_indices_sorted = True
        return self.__col_indices_sorted

    cdef _order_column_indices(self):
        """
        Order column indices by ascending order.

        We use a simple insert sort. The idea is that the column indices aren't that much not ordered.
        """
        #  must be called to find first row not ordered
        if self.are_column_indices_sorted():
            return

        cdef int i = self.__first_row_not_ordered
        cdef int col_index
        cdef int col_index_start
        cdef int col_index_stop

        while i < self.nrow:
            col_index = self.ind[i]
            col_index_start = col_index
            col_index_stop = self.ind[i+1]

            while col_index < col_index_stop - 1:
                # detect if row is not ordered
                if self.col[col_index] > self.col[col_index + 1]:
                    # sort
                    # TODO: maybe use the column index for optimization?
                    _sort(self.col, col_index_start, col_index_stop)
                    break
                else:
                    col_index += 1

            i += 1

    def order_column_indices(self):
        return self._order_column_indices()


    ####################################################################################################################
    # String representations
    ####################################################################################################################
    def __repr__(self):
        s = "CSRSparseMatrix of size %d by %d with %d non zero values" % (self.nrow, self.ncol, self.nnz)
        return s

    def print_to(self, OUT):
        """
        Print content of matrix to output stream.

        Args:
            OUT: Output stream that print (Python3) can print to.
        """
        # TODO: adapt to any numbers... and allow for additional parameters to control the output
        cdef int i, k, first = 1;

        cdef double *mat
        cdef int j
        cdef double val

        print('CSRSparseMatrix ([%d,%d]):' % (self.nrow, self.ncol), file=OUT)

        if not self.nnz or not self.__status_ok:
            return

        if self.nrow <= CSR_MAT_PPRINT_COL_THRESH and self.ncol <= CSR_MAT_PPRINT_ROW_THRESH:
            # create linear vector presentation
            # TODO: put in a method of its own
            mat = <double *> PyMem_Malloc(self.nrow * self.ncol * sizeof(double))

            if not mat:
                raise MemoryError()

            for i from 0 <= i < self.nrow:
                for j from 0 <= j < self.ncol:
                    mat[i* self.ncol + j] = 0.0

                k = self.ind[i]
                while k < self.ind[i+1]:
                    mat[(i*self.ncol)+self.col[k]] = self.val[k]
                    k += 1

            for i from 0 <= i < self.nrow:
                for j from 0 <= j < self.ncol:
                    val = mat[(i*self.ncol)+j]
                    #print('%9.*f ' % (6, val), file=OUT, end='')
                    print('{0:9.6f} '.format(val), end='')
                print()

            PyMem_Free(mat)

        else:
            print('Matrix too big to print out', file=OUT)

    ####################################################################################################################
    # DEBUG
    ####################################################################################################################
    def debug_print(self):
        cdef int i
        print("ind:")
        for i from 0 <= i < self.nrow + 1:
            print(self.ind[i], end=' ', sep=' ')
        print()

        print("col:")
        for i from 0 <= i < self.nnz:
            print(self.col[i], end=' ', sep=' ')
        print()

        print("val:")
        for i from 0 <= i < self.nnz:
            print(self.val[i], end=' == ', sep=' == ')
        print()

    def set_col(self, int i, int val):
        self.col[i] = val

########################################################################################################################
# Factory methods
########################################################################################################################
cdef MakeCSRSparseMatrix(int nrow, int ncol, int nnz, int * ind, int * col, double * val):
    """
    Construct a CSRSparseMatrix object.

    Args:
        nrow (int): Number of rows.
        ncol (int): Number of columns.
        nnz (int): Number of non-zeros.
        ind (int *): C-array with column indices pointers.
        col  (int *): C-array with column indices.
        val  (double *): C-array with values.
    """


    csr_mat = CSRSparseMatrix(nrow=nrow, ncol=ncol, nnz=nnz)

    csr_mat.val = val
    csr_mat.ind = ind
    csr_mat.col = col

    csr_mat.__status_ok = True

    return csr_mat