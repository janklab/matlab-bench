classdef BenchyPoo
  
  properties
    numIters (1,1) double = 100000
  end
  
  methods
    
    function benchAndWriteResults(this)
      this.benchAndWriteResultsImpl; % once to warm up the caches
      [outFile, langVer] = this.benchAndWriteResultsImpl; % and now for real
      fprintf('Matlab %s: wrote results to: %s\n', langVer, outFile);
    end
    
    function [outFile, langVer] = benchAndWriteResultsImpl(this)
      cpuId = getCpuId;
      lang = "Matlab";
      langVer = ['R' version('-release')];
      outBase = sprintf('%s - %s - %s.json', lang, langVer, platformName);
      cpuDir = fullfile(findResultsDir, cpuId);
      outFile = fullfile(cpuDir, outBase);
      rslts = struct;
      rslts = this.benchMethod(rslts);
      rslts = this.benchMethodInh3(rslts);
      rslts = this.benchProp(rslts);
      rslts = this.benchPropInh3(rslts);
      rslts = this.benchPropWrite(rslts);
      % Write results
      if ~isfolder(cpuDir)
        mkdir(cpuDir);
      end
      reportData = struct('meta', struct('lang', 'Matlab', 'version', langVer), ...
        'results', rslts);
      jsonText = jsonencode(reportData);
      spew(outFile, sprintf('%s\n', jsonText));
    end
    
    function rslts = benchMethod(this, rslts)
      obj = SomeClass;
      t0 = tic;
      for i = 1:this.numIters
        obj.foo();
      end
      te = toc_nsec(t0);
      nsecPerIter = te / this.numIters;
      rslts.method = nsecPerIter;
    end
    
    function rslts = benchMethodInh3(this, rslts)
      obj = SomeSubclass3;
      t0 = tic;
      for i = 1:this.numIters
        obj.foo();
      end
      te = toc_nsec(t0);
      nsecPerIter = te / this.numIters;
      rslts.method_inh3 = nsecPerIter;
    end
    
    function rslts = benchProp(this, rslts)
      obj = SomeClass;
      t0 = tic;
      for i = 1:this.numIters
        z = obj.x; %#ok<NASGU>
      end
      te = toc_nsec(t0);
      nsecPerIter = te / this.numIters;
      rslts.prop = nsecPerIter;
    end
    
    function rslts = benchPropInh3(this, rslts)
      obj = SomeSubclass3;
      t0 = tic;
      for i = 1:this.numIters
        z = obj.x; %#ok<NASGU>
      end
      te = toc_nsec(t0);
      nsecPerIter = te / this.numIters;
      rslts.prop_inh3 = nsecPerIter;
    end
    
    function rslts = benchPropWrite(this, rslts)
      obj = SomeClass;
      t0 = tic;
      for i = 1:this.numIters
        obj.x = i;
      end
      te = toc_nsec(t0);
      nsecPerIter = te / this.numIters;
      rslts.prop_write = nsecPerIter;
    end
    
  end
  
end

function out = toc_nsec(t0)
te = toc(t0);
out = te * 10^9;
end

function spew(file, text)
[fid,msg] = fopen(file, 'w');
if fid < 0
  error('Failed opening file %s: %s', file, msg);
end
fprintf(fid, '%s', text);
fclose(fid);
end

function out = platformName
if ispc
  out = "Windows";
elseif ismac
  out = "Mac";
else
  out = "Linux";
end
end

function out = getCpuId
out = getenv('BENCHMAT_CPU_ID');
if isempty(out)
  error('No BENCHMAT_CPU_ID environment variable defined. Can''t continue.');
end
end

function out = findResultsDir
myDir = fileparts(mfilename('fullpath'));
comparoDir = fileparts(fileparts(myDir));
out = fullfile(comparoDir, 'results');
end