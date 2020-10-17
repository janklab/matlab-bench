package buh;

import java.io.File;

import com.google.gson.Gson;
import com.google.common.io.Files;
import com.google.common.base.Charsets;
import com.google.gson.JsonIOException;

/**
 * Any sort of exception we encounter here.
 */
class BenchyException extends RuntimeException {

    // This is just here to satisfy inspections; it should never be used.
    static final long serialVersionUID = 420L;

    public BenchyException(String msg) {
        super(msg);
    }

}

public class BenchyPoo {

    static String fs = File.separator;

    int numIters = 100000;
    String outDir = ".." + fs + "results";

    public static void main(String[] args) {
        BenchyPoo b = new BenchyPoo();
        b.benchAndWriteResults();
    }

    public BenchyPoo() {

    }

    static double tic() {
        return System.nanoTime();
    }

    static double toc(double t0) {
        return System.nanoTime() - t0;
    }

    public void benchAndWriteResults() {
        // Run twice to warm up cache before recording results
        benchAndWriteResultsImpl();
        BenchWriteResults rslts = benchAndWriteResultsImpl();
        System.out.format("Java %s: wrote results to %s%n", rslts.langVer, rslts.outFile);
    }

    private BenchWriteResults benchAndWriteResultsImpl() {
        String cpuId = cpuId();
        String langVer = langVer();
        String platformName = detectPlatformName();
        String outBase = String.format("%s - %s - %s.json", "Java", langVer, platformName);
        String cpuDir = outDir + fs + cpuId;
        String outFile = cpuDir + fs + outBase;

        BenchResults rslts = new BenchResults();
        benchMethod(rslts);
        benchMethodInh3(rslts);
        benchProp(rslts);
        benchPropInh3(rslts);
        benchPropWrite(rslts);

        BenchReport report = new BenchReport();
        report.meta = new BenchReportMeta("Java", langVer);
        report.results = rslts;
        Gson gson = new Gson();
        String json = gson.toJson(report);
        try {
            Files.asCharSink(new File(outFile), Charsets.UTF_8).write(json + "\n");
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
        }

        return new BenchWriteResults(outFile, langVer);
    }

    void benchMethod(BenchResults rslts) {
        SomeClass obj = new SomeClass();
        double t0 = tic();
        for (int i = 0; i < numIters; i++) {
            obj.foo();
        }
        double te = toc(t0);
        rslts.method = te / numIters;
    }

    void benchMethodInh3(BenchResults rslts) {
        SomeSubclass3 obj = new SomeSubclass3();
        double t0 = tic();
        for (int i = 0; i < numIters; i++) {
            obj.foo();
        }
        double te = toc(t0);
        rslts.method_inh_3 = te / numIters;
    }

    void benchProp(BenchResults rslts) {
        SomeClass obj = new SomeClass();
        double t0 = tic();
        int x;
        for (int i = 0; i < numIters; i++) {
            x = obj.x;
        }
        double te = toc(t0);
        rslts.prop = te / numIters;
    }

    void benchPropInh3(BenchResults rslts) {
        SomeSubclass3 obj = new SomeSubclass3();
        double t0 = tic();
        int x;
        for (int i = 0; i < numIters; i++) {
            x = obj.x;
        }
        double te = toc(t0);
        rslts.prop_inh3 = te / numIters;
    }

    void benchPropWrite(BenchResults rslts) {
        SomeClass obj = new SomeClass();
        double t0 = tic();
        for (int i = 0; i < numIters; i++) {
            obj.x = i;
        }
        double te = toc(t0);
        rslts.prop_write = te / numIters;
    }

    static String cpuId() {
        String out = System.getenv("BENCHMAT_CPU_ID");
        if (out == null) {
            throw new RuntimeException("No BENCHMAT_CPU_ID environment variable defined. Can't continue.");
        }
        return out;
    }

    static String detectPlatformName() {
        String osStr = System.getProperty("os.name").toLowerCase();
        if (osStr.contains("win")) {
            return "Windows";
        } else if (osStr.contains("mac")) {
            return "Mac";
        } else {
            // This isn't really correct; could be other Unix, but this program doesn't run on
            // any non-Linux Unixes.
            return "Linux";
        }
    }

    static String langVer() {
        return System.getProperty("java.version");
    }

}

class BenchReport {
    BenchReportMeta meta;
    BenchResults results;
}

class BenchReportMeta {
    String lang;
    String lang_ver;
    BenchReportMeta(String lang, String lang_ver) {
        this.lang = lang;
        this.lang_ver = lang_ver;
    }
}

class BenchResults {
    double method;
    double method_inh_3;
    double prop;
    double prop_inh3;
    double prop_write;
}

class BenchWriteResults {
    String outFile;
    String langVer;

    public BenchWriteResults(String outFile, String langVer) {
        this.outFile = outFile;
        this.langVer = langVer;
    }

}
