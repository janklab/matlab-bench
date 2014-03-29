package net.apjanke.matlab_bench.bench_nops;
 
class DummyJavaClass {
	
	public DummyJavaClass() {

	}

	public void nop() {

	}

	public static void staticNop() {

	}

	public void callNop(int nIters) {
	    for (int i=0; i<nIters; i++) {
	        nop();
	    }
	}
}