function bench_anon_fcn_in_fcn(nIters, isDryRun)

name = '@()[] anonymous fcn (in fcn)';
anonNopFcn = @()[];
t0 = tic;
for i = 1:nIters
    anonNopFcn();
end
te = toc(t0);
show_result(name, nIters, te, isDryRun);
