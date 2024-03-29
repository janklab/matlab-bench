function bench_matlab_nops(doWarmupRun, nIters)
% Benchmark basic "no-op" operations of various sorts.
%
% bench_matlab_nops(doWarmupRun, nIters)
%
% DoWarmupRun (true*/false) is whether to do an unmeasured warmup run
% first before the main test run. You should leave this on.
%
% NIters (numeric, 100_000*) is the number of iterations of each operation
% to test. This is the number of iterations of the operation itself to run,
% not the overall test of that type of operation. The iterations are done
% in tight loops coded specifically to each operation's benchmark. Larger
% numbers give more accurate results (hopefully). Small numbers will
% definitely give bogus results.
%
% All arguments are optional.
%
% Displays the results to the console.

%#ok<*FVAL>

if nargin < 1 || isempty(doWarmupRun);  doWarmupRun = true;  end
if nargin < 2 || isempty(nIters);       nIters = 100000;     end
nWarmupIters = 10000;

myParentDir = fileparts(mfilename('fullpath'));

fprintf('\n');
display_system_info();
runNotes = {sprintf('nIters = %d', nIters)};
if ~doWarmupRun
    runNotes{end+1} = 'NO WARM-UP RUN';
end
fprintf('%s\n', strjoin(runNotes, ', '));
fprintf('\n');

% TODO: sanity checks: system load, detect tic/toc timer bugs

% Preparation

% Get our Java classes on the path
% Be sloppy and skip the try/catch or onCleanup() just in case that affects
% our timings.
myJavaJarFile = fullfile(myParentDir, 'java', 'matlab-bench-internals.jar');
javaaddpath(myJavaJarFile);

% Get our .NET assemblies on the path
if ispc
    myDotNetDir = [fileparts(mfilename('fullpath')) '/dotNet/bench_nops_dotNet/build/'];
    % Load .net assemblies
    NET.addAssembly([myDotNetDir '/bench_nops_netFw45.dll']);
    % NET.addAssembly([myDotNetDir '/netcoreapp2.1/bench_nops_netCore.dll']); % does not load
    NET.addAssembly([myDotNetDir '/netstandard2.0/bench_nops_netStandard.dll']);
end

% Warm-up pass
if doWarmupRun
    bench_nops_pass(nWarmupIters, true);
end

% Benchmarking pass
bench_nops_pass(nIters, false);

% Cleanup
javarmpath(myJavaJarFile);
if ispc
    % .NET dlls can't be unloaded; if needed, please restart Matlab.
end

end

function bench_nops_pass(nIters, isWarmupRun)

show_results_header(isWarmupRun);


name = 'nop() function';
t0 = tic;
for i = 1:nIters
    nop();
end
te = toc(t0);
show_result(name, nIters, te, isWarmupRun);

name = 'nop() subfunction';
t0 = tic;
for i = 1:nIters
    nop_subfunction();
end
te = toc(t0);
show_result(name, nIters, te, isWarmupRun);

bench_anonymous_function(nIters, isWarmupRun);

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
show_result(name, nIters, te, isWarmupRun);


name = 'nop() private fcn on @class';
obj = dummyclass;
t0 = tic;
call_private_nop(obj, nIters);
te = toc(t0);
clear obj;
show_result(name, nIters, te, isWarmupRun);


% MCOS methods
obj = dummymcos;

name = 'classdef nop(obj)';
t0 = tic;
for i = 1:nIters
    nop(obj);
end
te = toc(t0);
show_result(name, nIters, te, isWarmupRun);

name = 'classdef obj.nop()';
t0 = tic;
for i = 1:nIters
    obj.nop();
end
te = toc(t0);
show_result(name, nIters, te, isWarmupRun);

name = 'classdef private_nop(obj)';
t0 = tic;
obj.call_private_nop(nIters);
te = toc(t0);
show_result(name, nIters, te, isWarmupRun);

name = 'classdef class.static_nop()';
t0 = tic;
for i = 1:nIters
    dummymcos.static_nop();
end
te = toc(t0);
show_result(name, nIters, te, isWarmupRun);

name = 'classdef obj.static_nop()';
dummyobj = dummymcos;
t0 = tic;
for i = 1:nIters
    dummyobj.static_nop();
end
te = toc(t0);
show_result(name, nIters, te, isWarmupRun);

name = 'classdef constant';
t0 = tic;
for i = 1:nIters
    dummymcos.MY_CONSTANT;
end
te = toc(t0);
show_result(name, nIters, te, isWarmupRun);

name = 'classdef property';
t0 = tic;
for i = 1:nIters
    obj.foo;
end
te = toc(t0);
show_result(name, nIters, te, isWarmupRun);

name = 'classdef property with getter';
t0 = tic;
for i = 1:nIters
    obj.propWithGetter;
end
te = toc(t0);
show_result(name, nIters, te, isWarmupRun);

% End of MCOS methods
clear obj;

name = '+pkg.nop() function';
t0 = tic;
for i = 1:nIters
    dummypkg.nop_in_pkg();
end
te = toc(t0);
show_result(name, nIters, te, isWarmupRun);

name = '+pkg.nop() from inside +pkg';
t0 = tic;
dummypkg.call_nop_in_pkg(nIters);
te = toc(t0);
show_result(name, nIters, te, isWarmupRun);

name = 'feval(''nop'')';
fcnName = 'nop';
t0 = tic;
for i = 1:nIters
    feval(fcnName);
end
te = toc(t0);
clear fcnName;
show_result(name, nIters, te, isWarmupRun);

name = 'feval(@nop)';
fcn = @nop;
t0 = tic;
for i = 1:nIters
    feval(fcn);
end
te = toc(t0);
clear fcn;
show_result(name, nIters, te, isWarmupRun);

name = 'eval(''nop'')';
fcnName = 'nop()';
t0 = tic;
for i = 1:nIters
    eval(fcnName); %#ok<EVLCS> 
end
te = toc(t0);
clear fcnName;
show_result(name, nIters, te, isWarmupRun);

if ispc
    %% .NET tests
    % .NET 4.5
    netObj45 = bench_nops_netFw45.DummyNetClass;

    name = '.NET 4.5 obj.nop()';
    t0 = tic;
    for i = 1:nIters
        netObj45.nop();
    end
    te = toc(t0);
    show_result(name, nIters, te, isWarmupRun);

    name = '.NET 4.5 nop(obj)';
    t0 = tic;
    for i = 1:nIters
        nop(netObj45);
    end
    te = toc(t0);
    show_result(name, nIters, te, isWarmupRun);

    name = '.NET 4.5 feval(''nop'',obj)';
    fcnName = 'nop';
    t0 = tic;
    for i = 1:nIters
        feval(fcnName, netObj45);
    end
    te = toc(t0);
    clear fcnName;
    show_result(name, nIters, te, isWarmupRun);

    name = '.NET 4.5 Klass.staticNop()';
    t0 = tic;
    for i = 1:nIters
        bench_nops_netFw45.DummyNetClass.staticNop();
    end
    te = toc(t0);
    show_result(name, nIters, te, isWarmupRun);

    name = '.NET 4.5 obj.nop() from .NET';
    t0 = tic;
    netObj45.callNop(nIters);
    te = toc(t0);
    show_result(name, nIters, te, isWarmupRun);

    % End .NET 4.5 tests
    clear netObj45;

    % .NET Standard 2.0
    netObjStd2 = bench_nops_netStandard.DummyNetClass;

    name = '.NET std 2.0 obj.nop()';
    t0 = tic;
    for i = 1:nIters
        netObjStd2.nop();
    end
    te = toc(t0);
    show_result(name, nIters, te, isWarmupRun);

    name = '.NET std 2.0 nop(obj)';
    t0 = tic;
    for i = 1:nIters
        nop(netObjStd2);
    end
    te = toc(t0);
    show_result(name, nIters, te, isWarmupRun);

    name = '.NET std 2.0 feval(''nop'',obj)';
    fcnName = 'nop';
    t0 = tic;
    for i = 1:nIters
        feval(fcnName, netObjStd2);
    end
    te = toc(t0);
    clear fcnName;
    show_result(name, nIters, te, isWarmupRun);

    name = '.NET std 2.0 Klass.staticNop()';
    t0 = tic;
    for i = 1:nIters
        bench_nops_netStandard.DummyNetClass.staticNop();
    end
    te = toc(t0);
    show_result(name, nIters, te, isWarmupRun);

    name = '.NET std 2.0 obj.nop() from .NET';
    t0 = tic;
    netObjStd2.callNop(nIters);
    te = toc(t0);
    show_result(name, nIters, te, isWarmupRun);

    % End .NET tests
    clear netObjStd;
end


%% Java tests
try
    jObj = javaObject('net.apjanke.matlab_bench.bench_nops.DummyJavaClass');

    name = 'Java obj.nop()';
    t0 = tic;
    for i = 1:nIters
        jObj.nop();
    end
    te = toc(t0);
    show_result(name, nIters, te, isWarmupRun);

    name = 'Java nop(obj)';
    t0 = tic;
    for i = 1:nIters
        nop(jObj);
    end
    te = toc(t0);
    show_result(name, nIters, te, isWarmupRun);

    name = 'Java feval(''nop'',obj)';
    fcnName = 'nop';
    t0 = tic;
    for i = 1:nIters
        feval(fcnName, jObj);
    end
    te = toc(t0);
    clear fcnName;
    show_result(name, nIters, te, isWarmupRun);

    if ~is_octave
        name = 'Java Klass.staticNop()';
        t0 = tic;
        for i = 1:nIters
            net.apjanke.matlab_bench.bench_nops.DummyJavaClass.staticNop();
        end
        te = toc(t0);
        show_result(name, nIters, te, isWarmupRun);
    end

    name = 'Java obj.nop() from Java';
    t0 = tic;
    jObj.callNop(nIters);
    te = toc(t0);
    show_result(name, nIters, te, isWarmupRun);

catch err
    fprintf('Java tests errored: %s. Skipping.\n', err.message);
end

% End Java tests
clear jObj;

try
    name = 'MEX mexnop()';
    t0 = tic;
    for i = 1:nIters
        mexnop();
    end
    te = toc(t0);
    show_result(name, nIters, te, isWarmupRun);
catch err
    fprintf('MEX tests errored: %s. Skipping.\n', err.message);
end

name = 'builtin j()';
t0 = tic;
for i = 1:nIters
    j();
end
te = toc(t0);
show_result(name, nIters, te, isWarmupRun);


name = 'struct s.foo field access';
s = struct;
s.foo = [];
t0 = tic;
for i = 1:nIters
    s.foo;
end
te = toc(t0);
show_result(name, nIters, te, isWarmupRun);
clear s

name = 'obj.foo = 42 (unvalidated)';
obj = DummyClassWithValidators;
x = 42;
t0 = tic;
for i = 1:nIters
    obj.aWhatever = x;
end
te = toc(t0);
show_result(name, nIters, te, isWarmupRun);
clear obj x

name = 'obj.foo = 42 (double)';
obj = DummyClassWithValidators;
x = 42;
t0 = tic;
for i = 1:nIters
    obj.aDouble = x;
end
te = toc(t0);
show_result(name, nIters, te, isWarmupRun);
clear obj x

name = 'obj.foo = 42 ((1,1) double)';
obj = DummyClassWithValidators;
x = 42;
t0 = tic;
for i = 1:nIters
    obj.aScalarDouble = x;
end
te = toc(t0);
show_result(name, nIters, te, isWarmupRun);
clear obj x

name = 'obj.foo = 42 ({must...})';
obj = DummyClassWithValidators;
x = 42;
t0 = tic;
for i = 1:nIters
    obj.aFcnValidator = x;
end
te = toc(t0);
show_result(name, nIters, te, isWarmupRun);
clear obj x

name = 'isempty(persistent)';
t0 = tic;
call_isempty_on_persistent(nIters);
te = toc(t0);
show_result(name, nIters, te, isWarmupRun);

fprintf('\n');

end

function show_results_header(isDryRun)
if isDryRun
    return;
end
% Align 'μsec...' with 1s place instead of field beginning; looks better.
%fprintf('%-30s  %-6s   %-6s \n', 'Operation', 'Total', '  Per Call (μsec)');
fprintf('%-30s   %-12s \n', 'Operation', 'Time (μsec)');
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

