.. _cysparse_types:

====================================
:program:`CySparse`\'s types
====================================

Internally, :program:`CySparse` uses typed variables. As a :program:`Python` user, you don't have directly access to these types but you can ask for a specific type to be used through the use of simple (enum) arguments.
As a :program:`Cython` user however, you do have access to these types and you can (and should) use them in your :program:`Cython` programs. For every type, there is a corresponding (enum) argument. Types are written with
``_t`` as suffix: ``INT32_t``, ``COMPLEX256_t``. The corresponding (enum) arguments are simply the names of the types with ``_T`` as suffix. Thus the (enum) argument corresponding to type ``FLOAT64_t`` is ``FLOAT64_T``
(notice the capital ``T``).
 

Compatibility with :program:`NumPy`
=====================================

In short, :program:`CySparse`\'s types  are 100% compatible with the :program:`NumPy` corresponding types [#numpy_cysparse_compatible_types]_. 
There are some differences thought between the way both libraries treat their types and numbers. Read on. 

..  warning:: The behavior of similar types in :program:`NumPy` and :program:`CySparse` can be different!

..  _availabe_types:

Available types
===============

:program:`CySparse` has some types that can be used for indices and some types that can be used for elements.

Indices: integer numbers
--------------------------

Two index types exist: signed 32 and signed 64 bits integers. Internally, they are named ``INT32_t`` and ``ÌNT64_t``.

Elements: integers, real and complex numbers
-----------------------------------------------

:program:`CySparse` has three different families of element types:

- integers: simple and double precision signed integers (``INT32_t`` and ``INT64_t``).
- real numbers: simple, double and quadruple precision real numbers (``FLOAT32_t``, ``FLOAT64_t`` and ``FLOAT128_t``).
- complex numbers: simple and double precision complex numbers (``COMPLEX64_t``, ``COMPLEX128_t``, ``COMPLEX256_t``).

Quadruple precision has some limited support in :program:`C99` standard and :program:`Cython` and thus in :program:`CySparse`. The same can be said about complex number in general although the simple and double precision are quite 
well integrated. This is worth a warning:

..  warning:: Quadruple precision and complex numbers have some limitations.

Number's behavior in :program:`CySparse`
==========================================

The three families of element types behave somewhat differently.

Overflow on assignment
----------------------

Numbers do overflow [#overflow_depends_on_compiler]_. When assigning an integer number a value too big for its type, an ``OverflowError`` is raised.

..  code-block:: python

    B = ll_mat.NewLLSparseMatrix(size=2, dtype=types.INT32_T)

    B[1, 1] = 2**31
    
raises an ``OverflowError`` with the following message:

..  code-block:: bash

    Traceback (most recent call last):
      File "new_types.py", line 102, in <module>
        B[1, 1] = 2**31
      File "cysparse/sparse/ll_mat_matrices/ll_mat_INT32_t_INT32_t.pyx", line 538, in cysparse.sparse.ll_mat_matrices.ll_mat_INT32_t_INT32_t.LLSparseMatrix_INT32_t_INT32_t.__setitem__ (cysparse/sparse/ll_mat_matrices/ll_mat_INT32_t_INT32_t.c:6565)
    OverflowError: value too large to convert to int

When assigning a real or complex number a value that is too big for its type,
it is assigned `inf`, i.e. :math:`+\infty` **without** any warning: 

..  code-block:: python

    B = ll_mat.NewLLSparseMatrix(size=2, dtype=types.FLOAT32_T)

    B[0, 0] = 232
    B[0, 1] = 1.3
    B[1, 1] = 2**310

    B.print_to(sys.stdout)

prints:

..  code-block:: bash

    LLSparseMatrix [INT32_t, FLOAT32_t] (G, NZ, [2, 2])
    232.000000  1.300000 
      0.000000       inf 



Overflow on operation
-----------------------

We follow the :program:`C99` standard and let an overflow during an operation pass silently (and give strange results) without a warning.

Let's define a matrix with huge numbers:

..  code-block:: python

    B = ll_mat.NewLLSparseMatrix(size=2, dtype=types.INT32_T)

    B[0, 0] = 232
    B[0, 1] = 1.3
    B[1, 1] = 2**31 -1

    B.print_to(sys.stdout)

This prints:

..  code-block:: bash

    LLSparseMatrix [INT32_t, INT32_t] (G, NZ, [2, 2])
    232          1 
      0 2147483647 

Multiplying ``B`` by itself returns a strange result:

..  code-block:: python

    C = B * B
    C.print_to(sys.stdout)

prints:

..  code-block:: bash

    53824 -2147483417 
        0           1

 

``nan`` and ``inf``
----------------------

Like :program:`NumPy`, :program:`CySparse` defines ``nan`` and ``inf``. These are compatible with their :program:`NumPy` counterparts and can be used interchangebly. They are used internally as the `C99` standard recommends.

..  code-block:: python

    import cysparse.types.cysparse_types as types
    
    B = ll_mat.NewLLSparseMatrix(size=2, dtype=types.FLOAT64_T)

    B[0, 0] = 232
    B[0, 1] = 1.3
    B[1, 1] = types.inf

    B.print_to(sys.stdout)
    
This prints:

..  code-block:: bash

    LLSparseMatrix [INT32_t, FLOAT64_t] (G, NZ, [2, 2])
    232.000000  1.300000 
      0.000000       inf

If we multiply ``B`` by itself, we obtain:

..  code-block:: bash

    LLSparseMatrix [INT32_t, FLOAT64_t] (G, NZ, [2, 2])
    53824.000000       inf 
        0.000000       inf

as expected.

Types compatibilities (implicit castings)
-------------------------------------------

Whenever an integer is assigned a real number, :program:`CySparse` assigns the integer part, i.e. takes its ``floor()`` part. 

..  code-block:: python

    B = ll_mat.NewLLSparseMatrix(size=2, dtype=types.INT64_T)

    B[0, 0] = 232
    B[0, 1] = 1.3
    B[1, 1] = -0.89

This matrix is in fact:

..  code-block:: bash

    LLSparseMatrix [INT32_t, INT64_t] (G, NZ, [2, 2])
    232  1 
      0  0 

Complex number are compatible between them if they don't overflow but otherwise are **not** compatible
nor with the integer neither with the real numbers.

[TO BE DONE: write an example with complex numbers]

..  raw:: html

    <h4>Footnote</h4>
    
..  [#numpy_cysparse_compatible_types] Behind the hood, both libraries use :program:`C99` types (whenever :program:`NumPy` is compiled with a :program:`C99` compliant compiler).
    :program:`CySparse` doesn't offer as many different types as :program:`NumPy` though«.
    
..  [#overflow_depends_on_compiler] Overflow is compiler-dependent (and compilers are often system-dependent).
