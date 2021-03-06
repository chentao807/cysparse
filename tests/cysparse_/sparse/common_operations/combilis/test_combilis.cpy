#!/usr/bin/env python

"""
This file tests linear combinations for all matrix-likes objects.

The following expression:

:math:`2 * A - 3 * B`

is not computeted right away. Instead, a chain of lazy operator proxies are created.

"""

import unittest
from cysparse.sparse.ll_mat import *


########################################################################################################################
# Helpers
########################################################################################################################
def are_matrices_equal(A, B):
    real_A = A
    real_B = B

    try:
        real_A = A.to_ll()
    except:
        pass

    try:
        real_B = B.to_ll()
    except:
        pass

    A_nrow, A_ncol = real_A.shape
    B_nrow, B_ncol = real_B.shape

    if A_nrow != B_nrow or A_ncol != B_ncol:
        return False

    for i in xrange(A_nrow):
        for j in xrange(A_ncol):
            if real_A[i, j] != real_B[i, j]:
                return False

    return True


########################################################################################################################
# Tests
########################################################################################################################

NROW = 10
NCOL = 14
SIZE = 10


#######################################################################
# Case: store_symmetry == False, Store_zero==False
#######################################################################
class CySparsecombilisNoSymmetryNoZero_@class@_@index@_@type@_TestCase(unittest.TestCase):
    def setUp(self):

        self.nrow = NROW
        self.ncol = NCOL

        self.A = LinearFillLLSparseMatrix(nrow=self.nrow, ncol=self.ncol, dtype=@type|type2enum@, itype=@index|type2enum@)

        # numpy vectors
{% if class in ['TransposedSparseMatrix', 'ConjugateTransposedSparseMatrix'] %}
        self.x = np.empty(self.nrow, dtype=np.@type|type2enum|cysparse_type_to_numpy_type@)
{% else %}
        self.x = np.empty(self.ncol, dtype=np.@type|type2enum|cysparse_type_to_numpy_type@)
{% endif %}

{% if type in complex_list %}
        self.x.fill(2 + 2j)
{% else %}
        self.x.fill(2)
{% endif %}

{% if class == 'LLSparseMatrix' %}
        self.C = self.A

{% elif class == 'CSCSparseMatrix' %}
        self.C = self.A.to_csc()

{% elif class == 'CSRSparseMatrix' %}
        self.C = self.A.to_csr()

{% elif class == 'TransposedSparseMatrix' %}
        self.C = self.A.T

{% elif class == 'ConjugatedSparseMatrix' %}
        self.C = self.A.conj

{% elif class == 'ConjugateTransposedSparseMatrix' %}
        self.C = self.A.H

{% else %}
YOU SHOULD ADD YOUR NEW MATRIX CLASS HERE
{% endif %}

    ### Equality element by element

    def test_simple_addition(self):
        self.assertTrue(are_matrices_equal(self.C + self.C, 2 * self.C))

    def test_simple_substraction(self):
        self.assertTrue(are_matrices_equal(self.C + self.C - self.C, self.C))

    def test_complicated_addition(self):
        self.assertTrue(are_matrices_equal(2 * self.C + self.C - self.C - 2 * self.C.conj - self.C.conj, 2 * self.C - 3 * self.C.conj))

    def test_simple_commutative_scalar_multiplication(self):
        self.assertTrue(are_matrices_equal(4 * self.C, self.C * 4))

    def test_complicated_commutative_scalar_multiplication(self):
        self.assertTrue(are_matrices_equal(2 * self.C * 3, 6 * self.C))

    ### Equality of multiplication with a NumPy vector

    def test_simple_addition_with_a_numpy_vector(self):
        np.testing.assert_array_equal((self.C + self.C) * self.x, (2 * self.C) * self.x)

    def test_simple_substraction_with_a_numpy_vector(self):
        np.testing.assert_array_equal((self.C + self.C - self.C) * self.x, self.C * self.x)

    def test_complicated_addition_with_a_numpy_vector(self):
        np.testing.assert_array_equal((2 * self.C + self.C - self.C - 2 * self.C.conj - self.C.conj) * self.x, (2 * self.C - 3 * self.C.conj) * self.x)

    def test_simple_commutative_scalar_multiplication_with_a_numpy_vector(self):
        np.testing.assert_array_equal((4 * self.C) * self.x, (self.C * 4) * self.x)

    def test_complicated_commutative_scalar_multiplication_with_a_numpy_vector(self):
        np.testing.assert_array_equal((2 * self.C * 3) * self.x, (6 * self.C) * self.x)

#######################################################################
# Case: store_symmetry == True, Store_zero==False
#######################################################################
class CySparsecombilisWithSymmetryNoZero_@class@_@index@_@type@_TestCase(unittest.TestCase):
    def setUp(self):

        self.size = SIZE

        self.A = LinearFillLLSparseMatrix(size=self.size, dtype=@type|type2enum@, itype=@index|type2enum@, store_symmetry=True)

        # numpy vectors
        self.x = np.empty(self.size, dtype=np.@type|type2enum|cysparse_type_to_numpy_type@)
{% if type in complex_list %}
        self.x.fill(2 + 2j)
{% else %}
        self.x.fill(2)
{% endif %}

{% if class == 'LLSparseMatrix' %}
        self.C = self.A

{% elif class == 'CSCSparseMatrix' %}
        self.C = self.A.to_csc()

{% elif class == 'CSRSparseMatrix' %}
        self.C = self.A.to_csr()

{% elif class == 'TransposedSparseMatrix' %}
        self.C = self.A.T

{% elif class == 'ConjugatedSparseMatrix' %}
        self.C = self.A.conj

{% elif class == 'ConjugateTransposedSparseMatrix' %}
        self.C = self.A.H

{% else %}
YOU SHOULD ADD YOUR NEW MATRIX CLASS HERE
{% endif %}

    ### Equality element by element

    def test_simple_addition(self):
        self.assertTrue(are_matrices_equal(self.C + self.C, 2 * self.C))

    def test_simple_substraction(self):
        self.assertTrue(are_matrices_equal(self.C + self.C - self.C, self.C))

    def test_complicated_addition(self):
        self.assertTrue(are_matrices_equal(2 * self.C + self.C - self.C - 2 * self.C.conj - self.C.conj, 2 * self.C - 3 * self.C.conj))

    def test_simple_commutative_scalar_multiplication(self):
        self.assertTrue(are_matrices_equal(4 * self.C, self.C * 4))

    def test_complicated_commutative_scalar_multiplication(self):
        self.assertTrue(are_matrices_equal(2 * self.C * 3, 6 * self.C))

    ### Equality of multiplication with a NumPy vector

    def test_simple_addition_with_a_numpy_vector(self):
        np.testing.assert_array_equal((self.C + self.C) * self.x, (2 * self.C) * self.x)

    def test_simple_substraction_with_a_numpy_vector(self):
        np.testing.assert_array_equal((self.C + self.C - self.C) * self.x, self.C * self.x)

    def test_complicated_addition_with_a_numpy_vector(self):
        np.testing.assert_array_equal((2 * self.C + self.C - self.C - 2 * self.C.conj - self.C.conj) * self.x, (2 * self.C - 3 * self.C.conj) * self.x)

    def test_simple_commutative_scalar_multiplication_with_a_numpy_vector(self):
        np.testing.assert_array_equal((4 * self.C) * self.x, (self.C * 4) * self.x)

    def test_complicated_commutative_scalar_multiplication_with_a_numpy_vector(self):
        np.testing.assert_array_equal((2 * self.C * 3) * self.x, (6 * self.C) * self.x)


#######################################################################
# Case: store_symmetry == False, Store_zero==True
#######################################################################
class CySparsecombilisNoSymmetrySWithZero_@class@_@index@_@type@_TestCase(unittest.TestCase):
    def setUp(self):

        self.nrow = NROW
        self.ncol = NCOL

        self.A = LinearFillLLSparseMatrix(nrow=self.nrow, ncol=self.ncol, dtype=@type|type2enum@, itype=@index|type2enum@, store_zero=True)

        # numpy vectors
{% if class in ['TransposedSparseMatrix', 'ConjugateTransposedSparseMatrix'] %}
        self.x = np.empty(self.nrow, dtype=np.@type|type2enum|cysparse_type_to_numpy_type@)
{% else %}
        self.x = np.empty(self.ncol, dtype=np.@type|type2enum|cysparse_type_to_numpy_type@)
{% endif %}

{% if type in complex_list %}
        self.x.fill(2 + 2j)
{% else %}
        self.x.fill(2)
{% endif %}

{% if class == 'LLSparseMatrix' %}
        self.C = self.A

{% elif class == 'CSCSparseMatrix' %}
        self.C = self.A.to_csc()

{% elif class == 'CSRSparseMatrix' %}
        self.C = self.A.to_csr()

{% elif class == 'TransposedSparseMatrix' %}
        self.C = self.A.T

{% elif class == 'ConjugatedSparseMatrix' %}
        self.C = self.A.conj

{% elif class == 'ConjugateTransposedSparseMatrix' %}
        self.C = self.A.H

{% else %}
YOU SHOULD ADD YOUR NEW MATRIX CLASS HERE
{% endif %}

    ### Equality element by element

    def test_simple_addition(self):
        self.assertTrue(are_matrices_equal(self.C + self.C, 2 * self.C))

    def test_simple_substraction(self):
        self.assertTrue(are_matrices_equal(self.C + self.C - self.C, self.C))

    def test_complicated_addition(self):
        self.assertTrue(are_matrices_equal(2 * self.C + self.C - self.C - 2 * self.C.conj - self.C.conj, 2 * self.C - 3 * self.C.conj))

    def test_simple_commutative_scalar_multiplication(self):
        self.assertTrue(are_matrices_equal(4 * self.C, self.C * 4))

    def test_complicated_commutative_scalar_multiplication(self):
        self.assertTrue(are_matrices_equal(2 * self.C * 3, 6 * self.C))

    ### Equality of multiplication with a NumPy vector

    def test_simple_addition_with_a_numpy_vector(self):
        np.testing.assert_array_equal((self.C + self.C) * self.x, (2 * self.C) * self.x)

    def test_simple_substraction_with_a_numpy_vector(self):
        np.testing.assert_array_equal((self.C + self.C - self.C) * self.x, self.C * self.x)

    def test_complicated_addition_with_a_numpy_vector(self):
        np.testing.assert_array_equal((2 * self.C + self.C - self.C - 2 * self.C.conj - self.C.conj) * self.x, (2 * self.C - 3 * self.C.conj) * self.x)

    def test_simple_commutative_scalar_multiplication_with_a_numpy_vector(self):
        np.testing.assert_array_equal((4 * self.C) * self.x, (self.C * 4) * self.x)

    def test_complicated_commutative_scalar_multiplication_with_a_numpy_vector(self):
        np.testing.assert_array_equal((2 * self.C * 3) * self.x, (6 * self.C) * self.x)


#######################################################################
# Case: store_symmetry == True, Store_zero==True
#######################################################################
class CySparsecombilisWithSymmetrySWithZero_@class@_@index@_@type@_TestCase(unittest.TestCase):
    def setUp(self):

        self.size = SIZE

        self.A = LinearFillLLSparseMatrix(size=self.size, dtype=@type|type2enum@, itype=@index|type2enum@, store_symmetry=True, store_zero=True)

        # numpy vectors
        self.x = np.empty(self.size, dtype=np.@type|type2enum|cysparse_type_to_numpy_type@)
{% if type in complex_list %}
        self.x.fill(2 + 2j)
{% else %}
        self.x.fill(2)
{% endif %}

{% if class == 'LLSparseMatrix' %}
        self.C = self.A

{% elif class == 'CSCSparseMatrix' %}
        self.C = self.A.to_csc()

{% elif class == 'CSRSparseMatrix' %}
        self.C = self.A.to_csr()

{% elif class == 'TransposedSparseMatrix' %}
        self.C = self.A.T

{% elif class == 'ConjugatedSparseMatrix' %}
        self.C = self.A.conj

{% elif class == 'ConjugateTransposedSparseMatrix' %}
        self.C = self.A.H

{% else %}
YOU SHOULD ADD YOUR NEW MATRIX CLASS HERE
{% endif %}

    ### Equality element by element

    def test_simple_addition(self):
        self.assertTrue(are_matrices_equal(self.C + self.C, 2 * self.C))

    def test_simple_substraction(self):
        self.assertTrue(are_matrices_equal(self.C + self.C - self.C, self.C))

    def test_complicated_addition(self):
        self.assertTrue(are_matrices_equal(2 * self.C + self.C - self.C - 2 * self.C.conj - self.C.conj, 2 * self.C - 3 * self.C.conj))

    def test_simple_commutative_scalar_multiplication(self):
        self.assertTrue(are_matrices_equal(4 * self.C, self.C * 4))

    def test_complicated_commutative_scalar_multiplication(self):
        self.assertTrue(are_matrices_equal(2 * self.C * 3, 6 * self.C))

    ### Equality of multiplication with a NumPy vector

    def test_simple_addition_with_a_numpy_vector(self):
        np.testing.assert_array_equal((self.C + self.C) * self.x, (2 * self.C) * self.x)

    def test_simple_substraction_with_a_numpy_vector(self):
        np.testing.assert_array_equal((self.C + self.C - self.C) * self.x, self.C * self.x)

    def test_complicated_addition_with_a_numpy_vector(self):
        np.testing.assert_array_equal((2 * self.C + self.C - self.C - 2 * self.C.conj - self.C.conj) * self.x, (2 * self.C - 3 * self.C.conj) * self.x)

    def test_simple_commutative_scalar_multiplication_with_a_numpy_vector(self):
        np.testing.assert_array_equal((4 * self.C) * self.x, (self.C * 4) * self.x)

    def test_complicated_commutative_scalar_multiplication_with_a_numpy_vector(self):
        np.testing.assert_array_equal((2 * self.C * 3) * self.x, (6 * self.C) * self.x)


if __name__ == '__main__':
    unittest.main()

