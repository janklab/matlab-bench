classdef Reporter
  
  properties
    comparoDir
    resultsDir
  end
  
  methods
    
    function this = Reporter()
      this.comparoDir = fileparts(mfilename('fullpath'));
      this.resultsDir = fullfile(this.comparoDir, 'results');
    end
    
    function out = readResults(this, cpuId, langs)
      nLangs = height(langs);
      cpuDir = fullfile(this.resultsDir, cpuId);
      out = cell(1, nLangs);
      for i = 1:nLangs
        want = table2struct(langs(i,:));
        resultsFileBase = sprintf('%s - %s - %s.json', want.lang, want.langVer, want.os);
        resultsFile = fullfile(cpuDir, resultsFileBase);
        out{i} = jsondecode(fileread(resultsFile));
      end
    end
    
    function out = table_1(this)
      cpuId = "Intel W-2150B";
      langs = cell2table({
        "C++"     "unknown" "Mac"
        "Java"    "15"      "Mac"
        "Python"  "3.8.6"   "Mac"
        "Matlab"  "R2020b"  "Mac"
        }, 'VariableNames',{'lang','langVer','os'});
      tests = cell2table({
        "method"  "Method call"
        "prop"    "Property read"
        "prop_write"  "Property write"
        }, 'VariableNames',{'test','testName'});
      nLangs = height(langs);
      nTests = height(tests);
      nCols = nLangs + 1;
      rslts = this.readResults(cpuId, langs);
      
      langDescrs = compose("%s %s", langs.lang, langs.langVer);
      colNames = ["Operation" langDescrs'];
      c = cell(nTests, nCols);
      for i = 1:nTests
        c{i,1} = tests.testName(i);
        for j = 1:nLangs
          c{i,j+1} = round(rslts{j}.results.(tests.test(i)));
        end
      end
      out = cell2table(c, 'VariableNames',colNames);
    end
    
  end
  
end
