using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace bench_nops_netFw45
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
