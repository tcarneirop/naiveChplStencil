use BlockDist;




 const Space = {1..8, 1..8};

 // Declare a dense, Block-distributed domain.
 const DenseDom: domain(2) dmapped Block(boundingBox=Space) = Space;

 // Declare a sparse subdomain.
 // Since DenseDom is Block-distributed, SparseDom will be as well.
 var SparseDom: sparse subdomain(DenseDom);

 // Add some elements to the sparse subdomain.
 // SparseDom.bulkAdd is another way to do this that allows more control.
 SparseDom += [ (1,2), (3,6), (5,4), (7,8) ];

 // Declare a sparse array.
 // This array is also Block-distributed.
 var A: [SparseDom] int;

 A = 1;

 writeln( "A[(1, 1)] = ", A[1,1]);
 for (ij,x) in zip(SparseDom, A) {
   writeln( "A[", ij, "] = ", x, " on locale ", x.locale);
 }

// Results in this output when run on 4 locales:
// A[(1, 1)] = 0
// A[(1, 2)] = 1 on locale LOCALE0
// A[(3, 6)] = 1 on locale LOCALE1
// A[(5, 4)] = 1 on locale LOCALE2
// A[(7, 8)] = 1 on locale LOCALE3