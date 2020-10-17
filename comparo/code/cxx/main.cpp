#include <chrono>
#include <fstream>
#include <iostream>

using namespace std;

#if defined(WIN32) || defined(_WIN32) || defined(__WIN32__) || defined(__NT__)
  const char *os_name_char = "Windows";
#elif __APPLE__
  const char *os_name_char = "Mac";
#elif __linux__
  const char *os_name_char = "Linux";
#endif

std::chrono::time_point<std::chrono::high_resolution_clock> tic() {
    return std::chrono::high_resolution_clock::now();
}

double toc(std::chrono::time_point<std::chrono::high_resolution_clock> t0) {
    auto t1 = std::chrono::high_resolution_clock::now();
    auto te = t1 - t0;
    auto nanos = chrono::duration_cast<chrono::nanoseconds>(te);
    return nanos.count();
}

class SomeClass {
public:
    int x = 42;
    void foo() {
        x += 1;
    }
};

class SomeSubclass1: public SomeClass {

};

class SomeSubclass2: public SomeSubclass1 {

};

class SomeSubclass3: public SomeSubclass2 {

};

class Results {
public:
    double method = 0;
    double method_inh3 = 0;
    double prop = 0;
    double prop_inh3 = 0;
    double prop_write = 0;
};

class BenchyPoo {
public:
    string out_dir = "../results";
    int n_iters = 10000000;

    static string get_cpu_id() {
        return getenv("BENCHMAT_CPU_ID");
    }

    void bench_and_write_results() {
        bench_and_write_results_impl();
        bench_and_write_results_impl();
        cout << "C++: wrote results" << endl;
    }

    void bench_and_write_results_impl() const {
        string cpu_id = get_cpu_id();
        string lang = "C++";
        string os_name = os_name_char;
        // TODO: Detect compiler version
        string lang_ver = "unknown";
        int sbuf_siz = 8192;
        char sbuf[sbuf_siz];
        snprintf(sbuf, sbuf_siz, "%s - %s - %s.json", lang.c_str(), lang_ver.c_str(), os_name.c_str());
        string out_base = sbuf;
        snprintf(sbuf, sbuf_siz, "%s/%s/%s", out_dir.c_str(), cpu_id.c_str(), out_base.c_str());
        string out_file = sbuf;

        Results rslts;
        bench_method(&rslts);
        bench_method_inh3(&rslts);
        bench_prop(&rslts);
        bench_prop_inh3(&rslts);
        bench_prop_write(&rslts);

        snprintf(sbuf, sbuf_siz, "{\"meta\":{\"lang\":\"C++\",\"lang_ver\":\"unknown\"}, \"results\":{\"method\":%f,\"method_inh3\":%f,\"prop\":%f,\"prop_inh3\":%f,\"prop_write\":%f}}\n",
            rslts.method, rslts.method_inh3, rslts.prop, rslts.prop_inh3, rslts.prop_write);
        string json = sbuf;
        ofstream fh;
        fh.open(out_file);
        fh << json;
        fh.close();
    };

    void bench_method(Results *rslts) const {
        auto obj = new SomeClass();
        auto t0 = tic();
        for (int i = 0; i < n_iters; i++) {
            obj->foo();
        }
        auto te = toc(t0);
        rslts->method = te / n_iters;
    }

    void bench_method_inh3(Results *rslts) const {
        auto obj = new SomeSubclass3();
        auto t0 = tic();
        for (int i = 0; i < n_iters; i++) {
            obj->foo();
        }
        auto te = toc(t0);
        rslts->method_inh3 = te / n_iters;
    }

    void bench_prop(Results *rslts) const {
        auto obj = new SomeClass();
        auto t0 = tic();
        int x;
        for (int i = 0; i < n_iters; i++) {
            x = obj->x;
        }
        auto te = toc(t0);
        rslts->prop = te / n_iters;
    }

    void bench_prop_inh3(Results *rslts) const {
        auto obj = new SomeSubclass3();
        auto t0 = tic();
        int x;
        for (int i = 0; i < n_iters; i++) {
            x = obj->x;
        }
        auto te = toc(t0);
        rslts->prop_inh3 = te / n_iters;
    }

    void bench_prop_write(Results *rslts) const {
        auto obj = new SomeClass();
        auto t0 = tic();
        for (int i = 0; i < n_iters; i++) {
            obj->x = i;
        }
        auto te = toc(t0);
        rslts->prop_write = te / n_iters;
    }

};

int main() {
    BenchyPoo b;
    b.bench_and_write_results();
}
