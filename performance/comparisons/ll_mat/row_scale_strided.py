"""
This file compares different implementations of row_scale, i.e. scale the i:sup:`th` row of A by ``v[i]`` in place for ``i=0, ..., nrow-1``.

This time, we use a strided vector.

We compare the libraries:

- :program:`PySparse` and
- :program:`CySparse`.


"""

import benchmark
import numpy as np

# CySparse
from cysparse.sparse.ll_mat import LLSparseMatrix
from cysparse.common_types.cysparse_types import INT32_T, INT64_T, FLOAT64_T

# PySparse
from pysparse.sparse import spmatrix


########################################################################################################################
# Helpers
########################################################################################################################
def construct_sparse_matrix(A, n, nbr_elements):
    for i in xrange(nbr_elements):
        A[i % n, (2 * i + 1) % n] = i / 3


########################################################################################################################
# Benchmark
########################################################################################################################
class LLMatRowScaleStridedBenchmark(benchmark.Benchmark):


    label = "Simple row_scale with 100 elements and size = 1,000 and a strided NumPy vector (stride = 10)"
    each = 10


    def setUp(self):

        self.nbr_elements = 100
        self.size = 1000

        self.A_c = LLSparseMatrix(size=self.size, size_hint=self.nbr_elements, dtype=FLOAT64_T)
        construct_sparse_matrix(self.A_c, self.size, self.nbr_elements)

        self.A_p = spmatrix.ll_mat(self.size, self.size, self.nbr_elements)
        construct_sparse_matrix(self.A_p, self.size, self.nbr_elements)

        self.stride = 10

        self.v = np.arange(0, self.size * self.stride, dtype=np.float64)

    #def tearDown(self):
    #    for i in xrange(self.size):
    #        for j in xrange(self.size):
    #            assert self.A_c[i,j] == self.A_p[i,j]

    def test_pysparse(self):
        self.A_p.row_scale(self.v[::self.stride])
        return

    def test_cysparse(self):
        self.A_c.row_scale(self.v[::self.stride])
        return


class LLMatRowScaleStridedBenchmark_1(LLMatRowScaleStridedBenchmark):


    label = "Simple row_scale with 1000 elements and size = 10,000 and a strided NumPy vector (stride = 10)"
    each = 10


    def setUp(self):

        self.nbr_elements = 1000
        self.size = 10000

        self.A_c = LLSparseMatrix(size=self.size, size_hint=self.nbr_elements, dtype=FLOAT64_T)
        construct_sparse_matrix(self.A_c, self.size, self.nbr_elements)

        self.A_p = spmatrix.ll_mat(self.size, self.size, self.nbr_elements)
        construct_sparse_matrix(self.A_p, self.size, self.nbr_elements)

        self.stride = 10

        self.v = np.arange(0, self.size * self.stride, dtype=np.float64)


class LLMatRowScaleStridedBenchmark_2(LLMatRowScaleStridedBenchmark):


    label = "Simple row_scale with 10000 elements and size = 100,000 and a strided NumPy vector (stride = 10)"
    each = 10


    def setUp(self):

        self.nbr_elements = 10000
        self.size = 100000

        self.A_c = LLSparseMatrix(size=self.size, size_hint=self.nbr_elements, dtype=FLOAT64_T)
        construct_sparse_matrix(self.A_c, self.size, self.nbr_elements)

        self.A_p = spmatrix.ll_mat(self.size, self.size, self.nbr_elements)
        construct_sparse_matrix(self.A_p, self.size, self.nbr_elements)

        self.stride = 10

        self.v = np.arange(0, self.size * self.stride, dtype=np.float64)


class LLMatRowScaleStridedBenchmark_3(LLMatRowScaleStridedBenchmark):


    label = "Simple row_scale with 80000 elements and size = 100,000 and a strided NumPy vector (stride = 10)"
    each = 10


    def setUp(self):

        self.nbr_elements = 80000
        self.size = 100000

        self.A_c = LLSparseMatrix(size=self.size, size_hint=self.nbr_elements, dtype=FLOAT64_T)
        construct_sparse_matrix(self.A_c, self.size, self.nbr_elements)

        self.A_p = spmatrix.ll_mat(self.size, self.size, self.nbr_elements)
        construct_sparse_matrix(self.A_p, self.size, self.nbr_elements)

        self.stride = 10

        self.v = np.arange(0, self.size * self.stride, dtype=np.float64)


class LLMatRowScaleStridedBenchmark_4(LLMatRowScaleStridedBenchmark):


    label = "Simple row_scale with 10000 elements and size = 100,000 and a strided NumPy vector (stride = 739)"
    each = 10


    def setUp(self):

        self.nbr_elements = 10000
        self.size = 100000

        self.A_c = LLSparseMatrix(size=self.size, size_hint=self.nbr_elements, dtype=FLOAT64_T)
        construct_sparse_matrix(self.A_c, self.size, self.nbr_elements)

        self.A_p = spmatrix.ll_mat(self.size, self.size, self.nbr_elements)
        construct_sparse_matrix(self.A_p, self.size, self.nbr_elements)

        self.stride = 739

        self.v = np.arange(0, self.size * self.stride, dtype=np.float64)

if __name__ == '__main__':
    benchmark.main(format="markdown", numberFormat="%.4g")