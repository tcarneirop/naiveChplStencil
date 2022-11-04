use StencilDist;
use Time;

config const N = 10;
config const niters = 1;
config const printArrays = false;

const LocDom = {1..N  , 1..N  },
         Dom = LocDom dmapped Stencil(LocDom, fluff=(1,1)),
      BigDom = {0..N+1, 0..N+1} dmapped Stencil(LocDom, fluff=(1,1));

var A, B: [BigDom] real;
var heat: real = 0.0;

config const nsources = 3;
config const energy = 10;

var sources: [0..#nsources,0..1] int;


sources[0,0] = N/2; sources[0,1] = N/2; sources[1,0] = N/3; sources[1,1] = N/3;sources[2,0] = N*4/5; sources[2,1] = N*8/9;

for i in 0..#nsources do
  A[sources[i,0],sources[i,1]] += energy;


A.updateFluff();

if printArrays then
  writeln("Initial A:\n", A[Dom], "\n");

var numIters = 0;
var elapsed: Timer;
elapsed.start();

while(numIters<totaliters){
  numIters += 1;

  writeln("# iterations: ", numIters);

  forall (i,j) in Dom with(+ reduce heat) do{
      B[i,j] = A[i,j]/2.0 + (A[i-1,j] + A[i+1,j] + A[i,j-1] + A[i,j+1])/4.0/2.0;
      heat+=B[i,j];
  } 
  
  B <=> A;
  A.updateFluff();

}

elapsed.stop();
writeln("\n",heat, "\n");
  
writeln("### Elapsed time: ", elapsed.elapsed());

elapsed.clear();
    
if printArrays then
  writeln("Final A:\n", A[Dom]);
