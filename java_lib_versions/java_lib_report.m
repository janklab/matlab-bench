function java_lib_report(versionData)
%JAVA_LIB_REPORT Print a report of the Java library versions
%
% java_lib_report(versionData)
%
% versionData is what list_java_lib_versions returned.

x = versionData;

identified = x.identifiedLibs.data;
p('');
p('Identified Libraries:');
for i = 1:size(identified, 1)
    p('%-30s %-10s   (%s)', identified{i,[1 2 3]});
end
p('');

unidentified = x.unidentifiedJars.data;
p('Unidentified JARs:');
fmt = '%-45s %-32s    %-40s';
p(fmt, 'JAR File', 'MD5 Digest', 'SHA-1 Digest');
for i = 1:size(unidentified, 1)
    p(fmt, unidentified{i, [2 7 8]});
end
p('');

end

function p(fmt, varargin)
%P Print a line with fprintf formatting controls
fprintf([fmt '\n'], varargin{:});
end