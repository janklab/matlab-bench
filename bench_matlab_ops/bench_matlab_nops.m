function bench_matlab_nops(doDryRun, nIters)
%BENCH_MATLAB_NOPS Benchmark basic "no-op" operations
%
% bench_matlab_nops(doDryRun, nIters)

% TODO: See if buffered output matters. Should output be at end?


if nargin < 1 || isempty(doDryRun);  doDryRun = true;  end
if nargin < 2 || isempty(nIters);    nIters = 100000;  end

myJavaClassDir = fileparts(mfilename('fullpath'));

fprintf('\n');
display_system_info();
runNotes = '';
if ~doDryRun
    runNotes = [runNotes ' NO WARM-UP RUN'];
end
fprintf('nIters = %d %s\n\n', nIters, runNotes);

% TODO: sanity checks: system load, detect tic/toc timer bug

% Prep

% HACK: Get our Java classes on the path
% Be sloppy and skip the try/catch or onCleanup() just in case that affects
% our timings
javaaddpath(myJavaClassDir);

% Warm-up pass
if doDryRun
    bench_nops_pass(10000, 1);
end

% Benchmarking pass
bench_nops_pass(nIters, 0);

% Cleanup
javarmpath(myJavaClassDir);

end

function bench_nops_pass(nIters, isDryRun)

show_results_header(isDryRun);


name = 'nop() function';
t0 = tic;
for i = 1:nIters
    nop();
end
te = toc(t0);
show_result(name, nIters, te, isDryRun);

name = 'nop() subfunction';
t0 = tic;
for i = 1:nIters
    nop_subfunction();
end
te = toc(t0);
show_result(name, nIters, te, isDryRun);

bench_anonymous_function(nIters, isDryRun);

% Skip this one... it benches the same for me
%bench_anon_fcn_in_fcn(nIters, isDryRun);

name = 'nop(obj) method';
obj = dummyclass;
t0 = tic;
for i = 1:nIters
    nop(obj);
end
te = toc(t0);
clear obj;
show_result(name, nIters, te, isDryRun);


name = 'nop() private fcn on @class';
obj = dummyclass;
t0 = tic;
call_private_nop(obj, nIters);
te = toc(t0);
clear obj;
show_result(name, nIters, te, isDryRun);


% MCOS methods
obj = dummymcos;

name = 'classdef nop(obj)';
t0 = tic;
for i = 1:nIters
    nop(obj);
end
te = toc(t0);
show_result(name, nIters, te, isDryRun);

name = 'classdef obj.nop()';
t0 = tic;
for i = 1:nIters
    obj.nop();
end
te = toc(t0);
show_result(name, nIters, te, isDryRun);

name = 'classdef pivate_nop(obj)';
t0 = tic;
obj.call_private_nop(nIters);
te = toc(t0);
show_result(name, nIters, te, isDryRun);

name = 'classdef class.static_nop()';
t0 = tic;
for i = 1:nIters
    dummymcos.static_nop();
end
te = toc(t0);
show_result(name, nIters, te, isDryRun);

name = 'classdef constant';
t0 = tic;
for i = 1:nIters
    dummymcos.MY_CONSTANT;
end
te = toc(t0);
show_result(name, nIters, te, isDryRun);

name = 'classdef property';
t0 = tic;
for i = 1:nIters
    obj.foo;
end
te = toc(t0);
show_result(name, nIters, te, isDryRun);

name = 'classdef property with getter';
t0 = tic;
for i = 1:nIters
    obj.propWithGetter;
end
te = toc(t0);
show_result(name, nIters, te, isDryRun);

% End of MCOS methods
clear obj;

name = '+pkg.nop() function';
t0 = tic;
for i = 1:nIters
    dummypkg.nop_in_pkg();
end
te = toc(t0);
show_result(name, nIters, te, isDryRun);

name = '+pkg.nop() from inside +pkg';
t0 = tic;
dummypkg.call_nop_in_pkg(nIters);
te = toc(t0);
show_result(name, nIters, te, isDryRun);

name = 'feval(''nop'')';
fcnName = 'nop';
t0 = tic;
for i = 1:nIters
    feval(fcnName);
end
te = toc(t0);
clear fcnName;
show_result(name, nIters, te, isDryRun);

name = 'feval(@nop)';
fcn = @nop;
t0 = tic;
for i = 1:nIters
    feval(fcn);
end
te = toc(t0);
clear fcn;
show_result(name, nIters, te, isDryRun);

name = 'eval(''nop'')';
fcnName = 'nop()';
t0 = tic;
for i = 1:nIters
    eval(fcnName);
end
te = toc(t0);
clear fcnName;
show_result(name, nIters, te, isDryRun);

% Java tests
jObj = net.apjanke.matlab_bench.bench_nops.DummyJavaClass;

name = 'Java obj.nop()';
t0 = tic;
for i = 1:nIters
    jObj.nop();
end
te = toc(t0);
show_result(name, nIters, te, isDryRun);

name = 'Java nop(obj)';
t0 = tic;
for i = 1:nIters
    nop(jObj);
end
te = toc(t0);
show_result(name, nIters, te, isDryRun);

name = 'Java feval(''nop'',obj)';
fcnName = 'nop';
t0 = tic;
for i = 1:nIters
    feval(fcnName, jObj);
end
te = toc(t0);
clear fcnName;
show_result(name, nIters, te, isDryRun);


name = 'Java Klass.staticNop()';
t0 = tic;
for i = 1:nIters
    net.apjanke.matlab_bench.bench_nops.DummyJavaClass.staticNop();
end
te = toc(t0);
show_result(name, nIters, te, isDryRun);

name = 'Java obj.nop() from Java';
t0 = tic;
jObj.callNop(nIters);
te = toc(t0);
show_result(name, nIters, te, isDryRun);

% End Java tests
clear jObj;

name = 'MEX mexnop()';
t0 = tic;
for i = 1:nIters
    mexnop();
end
te = toc(t0);
show_result(name, nIters, te, isDryRun);


name = 'builtin j()';
t0 = tic;
for i = 1:nIters
    j();
end
te = toc(t0);
show_result(name, nIters, te, isDryRun);


name = 'struct s.foo field access';
s = struct;
s.foo = [];
t0 = tic;
for i = 1:nIters
    s.foo;
end
te = toc(t0);
show_result(name, nIters, te, isDryRun);
clear s

name = 'isempty(persistent)';
t0 = tic;
call_isempty_on_persistent(nIters);
te = toc(t0);
show_result(name, nIters, te, isDryRun);


end

function show_results_header(isDryRun)
if isDryRun
    return;
end
% Align 'msec...' with 1s place instead of field beginning; looks better.
%fprintf('%-30s  %-6s   %-6s \n', 'Operation', 'Total', '  Per Call (msec)');
fprintf('%-30s   %-12s \n', 'Operation', 'Time (msec)');
end

function call_isempty_on_persistent(nIters)

persistent foo
if isempty(foo)
    foo = 42;
end

for i = 1:nIters
    isempty(foo);
end

end


function bench_anonymous_function(nIters, isDryRun)
% Subfunction (local function) nop
name = '@()[] anonymous function';
anonNopFcn = @()[];
t0 = tic;
for i = 1:nIters
    anonNopFcn();
end
te = toc(t0);
show_result(name, nIters, te, isDryRun);

end

function nop_subfunction()
%NOP_SUBFUNCTION Subfunction (local function) that does nothing
end
