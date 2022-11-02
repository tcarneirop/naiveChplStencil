use DistributedIters;
use BlockDist;
use Time;

config const N = 16;
config const nsources = 3;
config const energy = 10;
config const niters = 1;

const Space = {0..N+1, 0..N+1};
const StencilSpace = {1..N, 1..N};

const D: domain(2) dmapped Block(boundingBox=Space) = Space;


var Anew: [D] real = 0.0;
var Aold: [D] real = 0.0;

var sources: [0..#nsources,0..1] int;

//{{n/2,n/2}, {n/3,n/3}, {n*4/5,n*8/9}};

sources[0,0] = N/2; sources[0,1] = N/2; sources[1,0] = N/3; sources[1,1] = N/3;sources[2,0] = N*4/5; sources[2,1] = N*8/9;


//stencil(Anew,Aold,sources,niters,3,energy);
//dynamicStencil(Anew,Aold,sources,niters,3,energy);
//secondDynamicStencil(Anew,Aold,sources,niters,3,energy);

proc stencil(ref Anew, ref Aold, ref sources, const niters: int, const nsources: int, const energy: int){

	for i in 0..#nsources do
		Aold[sources[i,0],sources[i,1]] += energy;
	
	var elapsed: Timer;
	var heat: real = 0.0; 

	for a in Aold do if a > 0 then write(" ",a);	


	elapsed.start();

	for i in 1..niters do{

		writeln("Iteration: ", i);

		forall (i, j) in StencilSpace with(+ reduce heat) do{
			Anew[i,j] = Aold[i,j]/2.0 + (Aold[i-1,j] + Aold[i+1,j] + Aold[i,j-1] + Aold[i,j+1])/4.0/2.0;
			heat+=Anew[i,j];			 
		}

		Anew<=>Aold;
	}
	elapsed.stop();

	//writeln(Anew);
	writeln("\n",heat, "\n");
	

	writeln("### Elapsed time: ", elapsed.elapsed());

    elapsed.clear();
        
}//proc



proc dynamicStencil(ref Anew, ref Aold, ref sources, const niters: int, const nsources: int, const energy: int){

	writeln("##### Dynamic Stencil #####");
	for i in 0..#nsources do
		Aold[sources[i,0],sources[i,1]] += energy;
	
	var elapsed: Timer;
	var heat: real = 0.0; 

	for a in Aold do if a > 0 then write(" ",a);	


	elapsed.start();

	for i in 1..niters do{

		writeln("Iteration: ", i);

		forall (i, j) in distributedDynamic(c=StencilSpace, parDim=1)  do{
			Anew[i,j] = Aold[i,j]/2.0 + (Aold[i-1,j] + Aold[i+1,j] + Aold[i,j-1] + Aold[i,j+1])/4.0/2.0;
			//heat+=Anew[i,j];			 
		}

		Anew<=>Aold;
	}
	elapsed.stop();

	//writeln(Anew);
	writeln("\n",heat, "\n");
	

	writeln("### Elapsed time: ", elapsed.elapsed());

    elapsed.clear();
        
}//proc



proc secondDynamicStencil(ref Anew, ref Aold, ref sources, const niters: int, const nsources: int, const energy: int){

	writeln("##### Second Dynamic Stencil #####");
	for i in 0..#nsources do
		Aold[sources[i,0],sources[i,1]] += energy;
	
	var elapsed: Timer;
	var heat: real = 0.0; 

	for a in Aold do if a > 0 then write(" ",a);	
	const mySpace = 1..N;

	elapsed.start();

	for it in 1..niters do{
		writeln("Iteration: ", it);
		[(i,j) in StencilSpace] Anew[i,j] = Aold[i,j]/2.0 + (Aold[i-1,j] + Aold[i+1,j] + Aold[i,j-1] + Aold[i,j+1])/4.0/2.0;
		Anew<=>Aold;
	}
	elapsed.stop();

	//writeln(Anew);
	writeln("\n",heat, "\n");
	

	writeln("### Elapsed time: ", elapsed.elapsed());

    elapsed.clear();
        
}//proc