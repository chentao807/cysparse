"""
This file compares different implementations of `to_csr()`.

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
class LLMatToCSRBenchmark(benchmark.Benchmark):


    label = "to_csr() with 100 elements and size = 1,000"
    each = 100

    def setUp(self):

        self.nbr_elements = 100
        self.size = 1000

        self.A_c = LLSparseMatrix(size=self.size, size_hint=self.nbr_elements, dtype=FLOAT64_T)
        construct_sparse_matrix(self.A_c, self.size, self.nbr_elements)

        self.A_p = spmatrix.ll_mat(self.size, self.size, self.nbr_elements)
        construct_sparse_matrix(self.A_p, self.size, self.nbr_elements)

    #def tearDown(self):

    #    for i in xrange(self.size):
    #        for j in xrange(self.size):
    #            assert self.csr_c[i, j] == self.A_c[i, j]


    def test_pysparse(self):
        self.csr_p = self.A_p.to_csr()
        return

    def test_cysparse(self):
        self.csr_c = self.A_c.to_csr()
        return


class LLMatToCSRBenchmark_1(LLMatToCSRBenchmark):


    label = "to_csr() with 1,000 elements and size = 10,000"
    each = 100

    def setUp(self):

        self.nbr_elements = 1000
        self.size = 10000

        self.A_c = LLSparseMatrix(size=self.size, size_hint=self.nbr_elements, dtype=FLOAT64_T)
        construct_sparse_matrix(self.A_c, self.size, self.nbr_elements)

        self.A_p = spmatrix.ll_mat(self.size, self.size, self.nbr_elements)
        construct_sparse_matrix(self.A_p, self.size, self.nbr_elements)


class LLMatToCSRBenchmark_2(LLMatToCSRBenchmark):


    label = "to_csr() with 10,000 elements and size = 100,000"
    each = 100

    def setUp(self):

        self.nbr_elements = 10000
        self.size = 100000

        self.A_c = LLSparseMatrix(size=self.size, size_hint=self.nbr_elements, dtype=FLOAT64_T)
        construct_sparse_matrix(self.A_c, self.size, self.nbr_elements)

        self.A_p = spmatrix.ll_mat(self.size, self.size, self.nbr_elements)
        construct_sparse_matrix(self.A_p, self.size, self.nbr_elements)


class LLMatToCSRBenchmark_3(LLMatToCSRBenchmark):


    label = "to_csr() with 80,000 elements and size = 100,000"
    each = 100

    def setUp(self):

        self.nbr_elements = 80000
        self.size = 100000

        self.A_c = LLSparseMatrix(size=self.size, size_hint=self.nbr_elements, dtype=FLOAT64_T)
        construct_sparse_matrix(self.A_c, self.size, self.nbr_elements)

        self.A_p = spmatrix.ll_mat(self.size, self.size, self.nbr_elements)
        construct_sparse_matrix(self.A_p, self.size, self.nbr_elements)


if __name__ == '__main__':
    benchmark.main(format="markdown", numberFormat="%.4g")