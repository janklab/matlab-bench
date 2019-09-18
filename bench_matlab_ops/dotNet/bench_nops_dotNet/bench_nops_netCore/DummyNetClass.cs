using System;

namespace bench_nops_netCore
{
    public class DummyNetClass
    {
        public void nop() { }
        public static void staticNop() { }
        public void callNop(int nIters)
        {
            for (int i = 0; i < nIters; i++)
            {
                nop();
            }
        }

    }
}
