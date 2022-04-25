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

	/**
	 * Main method just prints "Hello, world!". This is not
	 * used for anything; it's just here to make it easy to test
	 * loading this class in various JVMs.
	 */
	public static void main(String[] args) {
		System.out.println("Hello, world!");
	}
}
