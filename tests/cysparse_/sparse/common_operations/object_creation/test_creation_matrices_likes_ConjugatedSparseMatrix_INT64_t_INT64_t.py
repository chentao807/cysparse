#!/usr/bin/env python

"""
This file tests the creation of matrix like objects from :class:`LLSparesMatrix` matrices.

We test **all** types and the symmetric and general cases.
We only use the real parts of complex numbers.

"""
from cysparse.sparse.ll_mat import *
from cysparse.common_types.cysparse_types import *
import numpy as np

import unittest

import sys

########################################################################################################################
# Tests
########################################################################################################################
##################################
# Case Non Symmetric, Non Zero
##################################
class CySparseCreationMatrices_ConjugatedSparseMatrix_INT64_t_INT64_t_TestCase(unittest.TestCase):
    def setUp(self):
        self.nrow = 10
        self.ncol = 14

        self.A = LinearFillLLSparseMatrix(nrow=self.nrow, ncol=self.ncol, dtype=INT64_T, itype=INT64_T)




        self.C = self.A.conj


        print self.A

        print "=" * 80
        print self.C

    def test_equality_one_by_one(self):
        """
        We test matrix-like object equality one element by one element.
        """

        for i in xrange(self.nrow):
            for j in xrange(self.ncol):
                self.assertTrue(self.A[i, j] == self.C[i, j])



##################################
# Case Symmetric, Non Zero
##################################
class CySparseCreationSymmetricMatrices_ConjugatedSparseMatrix_INT64_t_INT64_t_TestCase(unittest.TestCase):
    def setUp(self):
        self.size = 14

        self.A = LinearFillLLSparseMatrix(size=self.size, dtype=INT64_T, itype=INT64_T, store_symmetry=True)


        self.C = self.A.conj


    def test_equality_one_by_one(self):
        """
        We test matrix-like object equality one element by one element.
        """

        for i in xrange(self.size):
            for j in xrange(self.size):
                self.assertTrue(self.A[i, j] == self.C[i, j])


##################################
# Case Non Symmetric, Zero
##################################
class CySparseCreationWithZeroMatrices_ConjugatedSparseMatrix_INT64_t_INT64_t_TestCase(unittest.TestCase):
    def setUp(self):
        self.nrow = 10
        self.ncol = 14

        self.A = LinearFillLLSparseMatrix(nrow=self.nrow, ncol=self.ncol, dtype=INT64_T, itype=INT64_T)


        self.C = self.A.conj


    def test_equality_one_by_one(self):
        """
        We test matrix-like object equality one element by one element.
        """

        for i in xrange(self.nrow):
            for j in xrange(self.ncol):
                self.assertTrue(self.A[i, j] == self.C[i, j])



##################################
# Case Symmetric, Zero
##################################
class CySparseCreationSymmetricWithZeroMatrices_ConjugatedSparseMatrix_INT64_t_INT64_t_TestCase(unittest.TestCase):
    def setUp(self):
        self.size = 14

        self.A = LinearFillLLSparseMatrix(size=self.size, dtype=INT64_T, itype=INT64_T, store_symmetry=True)


        self.C = self.A.conj


    def test_equality_one_by_one(self):
        """
        We test matrix-like object equality one element by one element.
        """

        for i in xrange(self.size):
            for j in xrange(self.size):
                self.assertTrue(self.A[i, j] == self.C[i, j])



if __name__ == '__main__':
    unittest.main()