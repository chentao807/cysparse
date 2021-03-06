#!python
#cython: boundscheck=False, wraparound=False, initializedcheck=False
    
from cysparse.common_types.cysparse_types cimport *
from cysparse.sparse.s_mat cimport SparseMatrix, unexposed_value, MUTABLE_SPARSE_MAT_DEFAULT_SIZE_HINT, MakeMatrixLikeString

from cysparse.sparse.sparse_proxies.t_mat cimport TransposedSparseMatrix


from cpython.mem cimport PyMem_Malloc, PyMem_Realloc, PyMem_Free

cdef extern from "Python.h":
    # *** Types ***
    Py_ssize_t PY_SSIZE_T_MAX
    int PyInt_Check(PyObject *o)
    long PyInt_AS_LONG(PyObject *io)

    # *** Slices ***
    ctypedef struct PySliceObject:
        pass

    # Cython's version doesn't work for all versions...
    int PySlice_GetIndicesEx(
        PySliceObject* s, Py_ssize_t length,
        Py_ssize_t *start, Py_ssize_t *stop, Py_ssize_t *step,
        Py_ssize_t *slicelength) except -1

    int PySlice_Check(PyObject *ob)

    # *** List ***
    int PyList_Check(PyObject *p)
    PyObject* PyList_GetItem(PyObject *list, Py_ssize_t index)
    Py_ssize_t PyList_Size(PyObject *list)

    PyObject* Py_BuildValue(char *format, ...)
    PyObject* PyList_New(Py_ssize_t len)
    void PyList_SET_ITEM(PyObject *list, Py_ssize_t i, PyObject *o)
    PyObject* PyList_GET_ITEM(PyObject *list, Py_ssize_t i)

########################################################################################################################
# BASE MATRIX CLASS
########################################################################################################################
cdef class SparseMatrix_INT32_t_FLOAT64_t(SparseMatrix):

    def __cinit__(self, **kwargs):
        """

        Warning:
            Only use named arguments! This is on purppose!
        """
        assert unexposed_value == kwargs.get('control_object', None), "Matrix must be instantiated with a factory method"

        self.__index_and_type = "[INT32_t, FLOAT64_t]"

        self.__base_type_str = "SparseMatrix"
        self.__full_type_str = "SparseMatrix %s" % self.__index_and_type

        self.cp_type.itype = INT32_T
        self.cp_type.dtype = FLOAT64_T

        self.__nrow = kwargs.get('nrow', -1)
        self.__ncol = kwargs.get('ncol', -1)

        assert self.__nrow != -1, "Number of rows must be given"
        assert self.__ncol != -1, "Number of columns must be given"

        if self.__store_symmetric:
            assert self.__nrow == self.__ncol, "A symmetric matrix must have equal number of rows and columns"

        self.__nnz = kwargs.get('nnz', 0)

        self.__nargin = self.__ncol
        self.__nargout = self.__nrow

        self.__transposed_proxy_matrix_generated = False



    
    @property
    def nrow(self):
        return self.__nrow

    
    @property
    def ncol(self):
        return self.__ncol

    
    @property
    def nnz(self):
        return self.__nnz

    
    @property
    def nargin(self):
        return self.__nargin

    
    @property
    def nargout(self):
        return self.__nargout

    
    @property
    def T(self):
        if not self.__transposed_proxy_matrix_generated:
            # create proxy
            self.__transposed_proxy_matrix = TransposedSparseMatrix(self)
            self.__transposed_proxy_matrix_generated = True

        return self.__transposed_proxy_matrix



    
    @property
    def H(self):
        return self.T

    
    @property
    def conj(self):
        return self


    ####################################################################################################################
    # Set/Get list of elements
    ####################################################################################################################
    ####################################################################################################################
    #                                            *** SET ***
    ####################################################################################################################
    #                                            *** GET ***
    def diags(self, diag_coeff):
        """
        Return a list wiht :program:`NumPy` arrays containings asked diagonals.

        Args:
            diag_coeff: Can be a list or a slice.

        Raises:
            - ``RuntimeError`` if slice is illformed;
            - ``TypeError`` if argument is not a ``list`` or ``slice``;
            - ``MemoryError`` if there is not enough memory for internal calculations;
            - ``ValueError`` if the list contains something else than integer indices;
            - ``AssertionError`` if internal calculations go wrong (should not happen...);
            - ``IndexError`` if the diagonals coefficients are out of bound.

        Note:
            Diagonal coefficients greater than ``n-1`` as disregarded when using a slice.
        """
        cdef INT32_t ret
        cdef Py_ssize_t start, stop, step, length, index, max_length

        cdef INT32_t i, j
        cdef INT32_t * indices
        cdef PyObject *val

        cdef PyObject * obj = <PyObject *> diag_coeff

        # normally, with slices, it is common in Python to chop off...
        # Here we only chop off from above, not below...
        # -m + 1 <= k <= n -1   : only k <= n - 1 will be satified (greater indices are disregarded)
        # but nothing is done if k < -m + 1
        max_length = self.__ncol

        # grab diag coefficients
        if PySlice_Check(obj):
            # slice
            ret = PySlice_GetIndicesEx(<PySliceObject*>obj, max_length, &start, &stop, &step, &length)
            if ret:
                raise RuntimeError("Slice could not be translated")

            #print "start, stop, step, length = (%d, %d, %d, %d)" % (start, stop, step, length)

            indices = <INT32_t *> PyMem_Malloc(length * sizeof(INT32_t))
            if not indices:
                raise MemoryError()

            # populate indices
            i = start
            for j from 0 <= j < length:
                indices[j] = i
                i += step

        elif PyList_Check(obj):
            length = PyList_Size(obj)
            indices = <INT32_t *> PyMem_Malloc(length * sizeof(INT32_t))
            if not indices:
                raise MemoryError()

            for i from 0 <= i < length:
                val = PyList_GetItem(obj, <Py_ssize_t>i)
                if PyInt_Check(val):
                    index = PyInt_AS_LONG(val)
                    indices[i] = <INT32_t> index
                else:
                    PyMem_Free(indices)
                    raise ValueError("List must only contain integers")
        else:
            raise TypeError("Index object is not recognized (list or slice)")

        diagonals = list()

        for i from 0 <= i < length:
            diagonals.append(self.diag(indices[i]))

        return diagonals

    ####################################################################################################################
    # CREATE SPECIAL MATRICES
    ####################################################################################################################
    def create_transpose(self):
        raise NotImplementedError('Not yet implemented. Please report.')



    ####################################################################################################################
    # MEMORY INFO
    ####################################################################################################################
    def memory_virtual_in_bits(self):
        """
        Return memory (in bits) needed if implementation would have kept **all** elements, not only the non zeros ones.

        Returns:
            The size in bits.

        Note:
            This method only returns the internal memory used for the C-arrays, **not** the whole object.
        """
        return FLOAT64_t_BIT * self.__nrow * self.__ncol

    def memory_virtual_in_bytes(self):
        """
        Return memory (in bits) needed if implementation would have kept **all** elements, not only the non zeros ones.

        Returns:
            The size in bytes.

        Note:
            This method only returns the internal memory used for the C-arrays, **not** the whole object.
        """

        return self.memory_virtual_in_bits() / CHAR_BIT

    def memory_real_in_bits(self):
        """
        Real memory used internally.

        Returns:
            The size in bits.

        Note:
            This method only returns the internal memory used for the C-arrays, **not** the whole object.
        """
        return self.memory_real_in_bytes() * CHAR_BIT

    def memory_real_in_bytes(self):
        """
        Real memory used internally.

        Returns:
            The size in bytes.

        Note:
            This method only returns the internal memory used for the C-arrays, **not** the whole object.
        """
        raise NotImplementedError()

    def memory_index_in_bits(self):
        """
        Return memory used for **one** index (in bits).


        """
        return INT32_t_BIT

    def memory_index_in_bytes(self):
        """
        Return memory used for **one** index (in bytes).


        """
        return INT32_t_BIT / CHAR_BIT

    def memory_element_in_bits(self):
        """
        Return memory used to store **one** element (in bits).


        """
        return FLOAT64_t_BIT

    def memory_element_in_bytes(self):
        """
        Return memory used to store **one** element (in bytes).


        """
        return FLOAT64_t_BIT / CHAR_BIT

    ####################################################################################################################
    # OUTPUT STRINGS
    ####################################################################################################################
    def matrix_short_description(self):
        """

        """
        s = "of size=(%d, %d) with %d non zero values" % (self.__nrow, self.__ncol, self.__nnz)
        return s

    def storage_scheme_string(self):
        symmetric_string = None
        if self.__store_symmetric:
            symmetric_string = 'Symmetric'
        else:
            symmetric_string = 'General'

        store_zero_string = None
        if self.__store_zero:
            store_zero_string = "with"
        else:
            store_zero_string = "without"

        s = '%s and %s zeros' % (symmetric_string, store_zero_string)

        return s

    def _matrix_description_before_printing(self):
        s = "%s %s <Storage scheme: %s>" % (self.__full_type_str, self.matrix_short_description(), self.storage_scheme_string())
        return s

    def __repr__(self):
        """
        Return an "unique" representation of the :class:`SparseMatrix` object.

        """
        return self._matrix_description_before_printing()

    def __str__(self):
        """
        Return a string to print the :class:`SparseMatrix` object to screen.

        """
        s = self._matrix_description_before_printing()
        s += '\n'
        s += MakeMatrixLikeString(self)

        return s



########################################################################################################################
# BASE MUTABLE MATRIX CLASS
########################################################################################################################
cdef class MutableSparseMatrix_INT32_t_FLOAT64_t(SparseMatrix_INT32_t_FLOAT64_t):
    def __cinit__(self, **kwargs):
        """

        Warning:
            We only use named arguments! This is on purppose!

        """
        self.size_hint = kwargs.get('size_hint', MUTABLE_SPARSE_MAT_DEFAULT_SIZE_HINT)

        # test to bound memory allocation
        if self.size_hint > self.nrow * self.ncol:
            self.size_hint = self.nrow *  self.ncol

        self.nalloc = 0
        self.__is_mutable = True


########################################################################################################################
# BASE IMMUTABLE MATRIX CLASS
########################################################################################################################
cdef class ImmutableSparseMatrix_INT32_t_FLOAT64_t(SparseMatrix_INT32_t_FLOAT64_t):
    def __cinit__(self, **kwargs):
        """

        Warning:
            We only use named arguments! This is on purppose!
        """
        self.__is_mutable = False