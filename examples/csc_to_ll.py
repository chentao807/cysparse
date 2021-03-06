from cysparse.sparse.ll_mat import *

nrow = 3
ncol = 4
nbr_elements = 4

A = LLSparseMatrix(nrow=nrow, ncol=ncol, size_hint=nbr_elements, itype=INT32_T, dtype=FLOAT64_T)

A.put_triplet([0,0,1,1], [1,2,0,2], [1.0, 2.0, 3.0, 4.0])
print A

A.debug_print()

print "T" * 80

A_CSC = A.to_csc()

print A_CSC

print '%' * 80

A_bis = A_CSC.to_ll()
A_bis.debug_print()

print A_bis

A_bis.compress()

print A_bis

A_bis[2,2] = 9.88

print A_bis

print "?" * 80

B = LinearFillLLSparseMatrix(nrow=3, ncol=3, first_element=1-6j, step=2+5j, dtype=COMPLEX64_T, store_symmetric=True)
B.compress()
B.debug_print()

print B
B_CSC = B.to_csc()
B_bis = B_CSC.to_ll()

print B_bis
B_bis.debug_print()