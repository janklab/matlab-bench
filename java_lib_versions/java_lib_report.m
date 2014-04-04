function java_lib_report(versionData)
%JAVA_LIB_REPORT Print a report of the Java library versions
%
% java_lib_report(versionData)
%
% Displays a report summarizing the results of list_java_lib_versions.
%
% versionData is what list_java_lib_versions returned.

x = versionData;

identified = x.identifiedLibs.data;
p('');
p('matlab-bench java_lib_versions report');
p('Matlab %s on %s, run at %s', x.meta.version, x.meta.computer, datestr(x.meta.timestamp));
p('');
p('Identified Libraries:');
fmt = '%-30s %-10s   %-15s     %-20s';
p(fmt, 'Lib', 'Version', 'InfoSource', 'MavenGroupId');
pheaderlines(fmt, '=');
for i = 1:size(identified, 1)
    p(fmt, identified{i,[1 2 3 4]});
end
p('');

unidentified = x.unidentifiedJars.data;
p('Unidentified JARs:');
fmt = '%-45s %-32s    %-40s';
p(fmt, 'JAR File', 'MD5 Digest', 'SHA-1 Digest');
pheaderlines(fmt, '=');
for i = 1:size(unidentified, 1)
    p(fmt, unidentified{i, [2 7 8]});
end
p('');

end

function p(fmt, varargin)
%P Print a line with fprintf formatting controls
fprintf([fmt '\n'], varargin{:});
end

function pheaderlines(fmt, lineChar)
%PHEADERLINES Print column header lines for a given record format
if nargin < 2 || isempty(lineChar);  lineChar = '-';  end
[match,tok] = regexp(fmt, '%-?(\d+)[a-z]', 'match','tokens');
lens = str2double([tok{:}]);
for i = 1:numel(lens)
    bars{i} = repmat(lineChar, [1 lens(i)]);
end
p(fmt, bars{:});
end