function show_result(name, nIters, te, isDryRun)
%SHOW_RESULT Show result for one operation style
if isDryRun
    return;
end
usecPerOp = (te * 10^6) / nIters;
%fprintf('%-30s  %6.4f  %6.2f \n', [name ':'], te, usecPerOp);
fprintf('%-30s  %12.2f \n', [name ':'], usecPerOp);

end
