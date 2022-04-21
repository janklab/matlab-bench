function show_result(name, nIters, te, isDryRun)
%SHOW_RESULT Show result for one operation style

if isDryRun
    return;
end
usecPerOp = (te * 10^6) / nIters;
%fprintf('%-30s  %6.3f  %6.3f \n', [name ':'], te, usecPerOp);
fprintf('%-30s  %12.3f \n', [name ':'], usecPerOp);

end
