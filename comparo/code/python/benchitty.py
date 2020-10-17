from datetime import datetime
import json
import os
import pathlib
import platform
import sys
import time


def tic():
  """Current time in float nanoseconds"""
  return time.time_ns()

def toc(t0):
  """Elapsed time in float nanoseconds"""
  t1 = tic()
  return t1 - t0

def _platform_name():
  """Name of system to be used in results database."""
  sys_name = platform.system()
  if sys_name == "Darwin":
    out = "Mac"
  elif sys_name == "Windows":
    out = "Windows"
  elif sys_name == "Linux":
    out = "Linux"
  else:
    raise Exception(f"WTF platform is '{sys_name}'???")
  return out


class BenchyPoo:
  def __init__(self):
    self.out_dir = "../results"
    self.out_file = os.path.join(self.out_dir, )
    self.n_iters = 100000
  
  def cpu_id(self):
    if not 'BENCHMAT_CPU_ID' in os.environ:
      raise("No BENCHMAT_CPU_ID environment variable defined. Can't continue.")
    return os.environ['BENCHMAT_CPU_ID']

  def lang_ver(self):
    vi = sys.version_info
    return '%s.%s.%s' % (vi.major, vi.minor, vi.micro)

  def bench_and_write_results(self):
    # Run it twice to make sure the caches are warmed up
    self._bench_and_write_results_impl()
    out_file, lang_ver = self._bench_and_write_results_impl()
    print(f'Python {lang_ver}: wrote results to: {out_file}')

  def _bench_and_write_results_impl(self):
    cpu_id = self.cpu_id()
    lang = "Python"
    lang_ver = self.lang_ver()
    out_base = '%s - %s - %s.json' % (lang, lang_ver, _platform_name())
    cpu_dir = os.path.join(self.out_dir, cpu_id)
    out_file = os.path.join(cpu_dir, out_base)
    rslts = {}
    self.bench_method(rslts)
    self.bench_method_inh3(rslts)
    self.bench_prop(rslts)
    self.bench_prop_inh3(rslts)
    self.bench_prop_write(rslts)
    report = {
      'meta': {'lang': 'Python', 'version': lang_ver},
      'results': rslts
    }
    pathlib.Path(cpu_dir).mkdir(parents=True, exist_ok=True)
    with open(out_file, 'w') as f:
      json.dump(report, f)
    return (out_file, lang_ver)

  def bench_method(self, rslts):
    o = SomeClass()
    t0 = tic()
    for i in range(self.n_iters):
      o.foo()
    te = toc(t0)
    nsec_per_iter = te / self.n_iters
    rslts['method'] = nsec_per_iter

  def bench_method_inh3(self, rslts):
    o = SomeSubclass3()
    t0 = tic()
    for i in range(self.n_iters):
      o.foo()
    te = toc(t0)
    nsec_per_iter = te / self.n_iters
    rslts['method_inh_3'] = nsec_per_iter

  def bench_prop(self, rslts):
    o = SomeClass()
    t0 = tic()
    for i in range(self.n_iters):
      dummy = o.x
    te = toc(t0)
    nsec_per_iter = te / self.n_iters
    rslts['prop'] = nsec_per_iter

  def bench_prop_inh3(self, rslts):
    o = SomeSubclass3()
    t0 = tic()
    for i in range(self.n_iters):
      dummy = o.x
    te = toc(t0)
    nsec_per_iter = te / self.n_iters
    rslts['prop_inh3'] = nsec_per_iter

  def bench_prop_write(self, rslts):
    o = SomeClass()
    t0 = tic()
    for i in range(self.n_iters):
      o.x = i
    te = toc(t0)
    nsec_per_iter = te / self.n_iters
    rslts['prop_write'] = nsec_per_iter

class SomeClass:
  def __init__(self):
    self.x = 42

  def foo(self):
    pass


class SomeSubclass1(SomeClass):
  pass


class SomeSubclass2(SomeSubclass1):
  pass


class SomeSubclass3(SomeSubclass2):
  pass