function out = compareStringAndCharOps(nIters, groupsToRun)
% Compare speed of equivalent string and char array operations.
%
% out = compareStringAndCharOps(nIters, groupsToRun)
%
% It is recommended that you call this function a few times, to let the
% Matlab interpreter and JIT warm up.
%
% nIters is the number of times to run each test.
%
% Returns a struct, whose format is subject to change. If output is not
% captured, displays the results in human-readable format.

% Developer notes:
%
% * Avoid using timeit and anonymous functions, because that introduces
% overhead.
%
% * For really small operations, garbage collection of temporary values is
% probably significantly influencing results.

arguments
    nIters (1,1) double = NaN
    groupsToRun string = []
end
if isnan(nIters)
    nIters = 10000;
end
allTestGroups = ["convert" "extract" "regexp"];
if isempty(groupsToRun)
    groupsToRun = allTestGroups;
end
badGroups = setdiff(groupsToRun, allTestGroups);
if ~isempty(badGroups)
    error('Invalid test groups: %s\n', strjoin(badGroups, " "));
end


%#ok<*NASGU>
%#ok<*AGROW>

% Localized randstream with fixed seed for reproducible runs
myRand = RandStream('mt19937ar', 'Seed', 420.69);

% { Name, CharTime, StringTime; ... }
rsltsBuf = {
    };

    function [out,outStr] = makeRandomString(nChars)
        out = char(myRand.randi([33 127], 1, nChars));
        outStr = string(out);
    end

% Tests

if ismember("convert", groupsToRun)
    
    % Construct a string
    
    for strLen = [1 1000 100000]
        name = sprintf('Construct from char, n=%d', strLen);
        [chr,str] = makeRandomString(strLen);
        t0 = tic;
        for i = 1:nIters
            % TODO: Would it be more realistic to trigger a CoW here?
            foo = chr;
        end
        teChar = toc(t0);
        t0 = tic;
        for i = 1:nIters
            foo = string(chr);
        end
        teStr = toc(t0);
        rsltsBuf = [rsltsBuf; {name, teChar, teStr}];
    end
    
    % Extract one string as char
    
    for strLen = [1 1000 100000]
        name = sprintf('Convert scalar string as char for (s{1}), n=%d', strLen);
        [chr,str] = makeRandomString(strLen);
        t0 = tic;
        for i = 1:nIters
            foo = chr;
        end
        teChar = toc(t0);
        t0 = tic;
        for i = 1:nIters
            foo = str{1};
        end
        teStr = toc(t0);
        rsltsBuf = [rsltsBuf; {name, teChar, teStr}];
    end
    
    for strLen = [1 1000 100000]
        name = sprintf('Convert scalar string as char for (char(s)), n=%d', strLen);
        [chr,str] = makeRandomString(strLen);
        t0 = tic;
        for i = 1:nIters
            foo = chr;
        end
        teChar = toc(t0);
        t0 = tic;
        for i = 1:nIters
            foo = char(str);
        end
        teStr = toc(t0);
        rsltsBuf = [rsltsBuf; {name, teChar, teStr}];
    end
    
    % Implicit conversion to char
    
    for strLen = [1 100 1000 10000 100000]
        name = sprintf('Impl conv to from variable scalar char, n=%d', strLen);
        [chr,str] = makeRandomString(strLen);
        charOneChar = 'x';
        t0 = tic;        
        for i = 1:nIters
            chr(1) = charOneChar;
        end
        teChar = toc(t0);
        strOneChar = "x";
        t0 = tic;
        for i = 1:nIters
            chr(1) = strOneChar;
        end
        teStr = toc(t0);
        rsltsBuf = [rsltsBuf; {name, teChar, teStr}];
    end
    
    for strLen = [1 100 1000 10000 100000]
        name = sprintf('Impl conv from literal to scalar char, n=%d', strLen);
        [chr,str] = makeRandomString(strLen);
        t0 = tic;
        for i = 1:nIters
            chr(1) = 'x';
        end
        teChar = toc(t0);
        t0 = tic;
        for i = 1:nIters
            chr(1) = "x";
        end
        teStr = toc(t0);
        rsltsBuf = [rsltsBuf; {name, teChar, teStr}];
    end    
    
end

if ismember("extract", groupsToRun)
    
    % Extract text
    
    for strLen = [100 1000]
        name = sprintf('Extract scattered ixed substr (c(ix) vs extract), n=%d', strLen);
        [chr,str] = makeRandomString(strLen);
        ix = myRand.randi(strLen, 1, floor(strLen/10));
        t0 = tic;
        for i = 1:nIters
            foo = chr(ix);
        end
        teChar = toc(t0);
        t0 = tic;
        for i = 1:nIters
            foo = repmat(' ', [1 numel(ix)]);
            for iChr = 1:numel(ix)
                foo(iChr) = extract(str, ix(iChr));
            end
        end
        teStr = toc(t0);
        rsltsBuf = [rsltsBuf; {name, teChar, teStr}];
    end
    
end


% Some regexps

if ismember("regexp", groupsToRun)
    
    name = 'regexp match';
    thisFile = [mfilename('fullpath') '.m'];
    chr = fileread(thisFile);
    str = string(chr);
    pat = 'makeRandomString.*rsltsBuf';
    patStr = string(pat);
    t0 = tic;
    for i = 1:nIters
        [a,b] = regexp(chr, pat);
    end
    teChar = toc(t0);
    t0 = tic;
    for i = 1:nIters
        [a,b] = regexp(str, patStr);
    end
    teStr = toc(t0);
    rsltsBuf = [rsltsBuf; {name, teChar, teStr}];
    
    name = 'regexp capture one big token';
    thisFile = [mfilename('fullpath') '.m'];
    chr = fileread(thisFile);
    str = string(chr);
    pat = 'makeRandomString.*rsltsBuf';
    patStr = string(pat);
    t0 = tic;
    for i = 1:nIters
        [a,b] = regexp(chr, pat, 'start', 'tokens');
    end
    teChar = toc(t0);
    t0 = tic;
    for i = 1:nIters
        [a,b] = regexp(str, patStr, "start", "tokens");
    end
    teStr = toc(t0);
    rsltsBuf = [rsltsBuf; {name, teChar, teStr}];

    name = 'regexp capture many little tokens';
    thisFile = [mfilename('fullpath') '.m'];
    chr = fileread(thisFile);
    str = string(chr);
    pat = 'rslts\.\w+';
    patStr = string(pat);
    t0 = tic;
    for i = 1:nIters
        [a,b] = regexp(chr, pat, 'start', 'tokens');
    end
    teChar = toc(t0);
    t0 = tic;
    for i = 1:nIters
        [a,b] = regexp(str, patStr, "start", "tokens");
    end
    teStr = toc(t0);
    rsltsBuf = [rsltsBuf; {name, teChar, teStr}];
    
end

% Results

rslts = cell2table(rsltsBuf, 'VariableNames', {'Name', 'CharTime', 'StringTime'});
nanosPerSec = 1000000000;
rslts.CharNsec = rslts.CharTime * nanosPerSec / nIters;
rslts.StringNsec = rslts.StringTime * nanosPerSec / nIters;
rslts.StringWin = (rslts.CharNsec - rslts.StringNsec) ./ rslts.CharNsec;
rslts = rslts(:,{'Name','CharNsec','StringNsec','StringWin'});
rslts.Name = categorical(rslts.Name); % for cosmetics

out.MatlabVer = version;
out.MatlabRelease = version('-release');
out.SystemInfo = display_system_info;
out.Results = rslts;

if nargout == 0
    % Round for cosmetics
    rslts.CharNsec = int64(round(rslts.CharNsec));
    rslts.StringNsec = int64(round(rslts.StringNsec));
    rslts.StringWin = round(rslts.StringWin, 2);
    
    fprintf('String vs. char benchmark:\n');
    fprintf('\n');
    fprintf('Matlab R%s on %s\n', out.MatlabRelease, computer);
    fprintf('OS: %s\n', out.SystemInfo.OsDescr);
    fprintf('%s, %d GB RAM %s\n', out.SystemInfo.CpuDescr, out.SystemInfo.MemSizeGB, ...
        out.SystemInfo.SystemExtra);
    fprintf('\n');
    disp(rslts);
    clear out
end

end
