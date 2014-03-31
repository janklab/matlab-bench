function list_java_lib_versions()
%LIST_JAVA_LIB_VERSIONS Lists versions of Java libraries in this Matlab
%
% This attempts to detect the versions of the Java libraries bundled with
% this version of Matlab.

% TODO: Get a list of md5sums for known versions of JARs, so we can
% determine versions of JARs that don't list versions in their manifest
% by comparing against MD5s of known distributions.

% TODO: Use the Maven "Provenance" tool to look up other JARs.
% From: https://github.com/armhold/Provenance

% TODO: How to map the JARs to a higher-level library name thing?
% * Hand-maintain a map of (library, jarfile) relationships?

p = sort(javaclasspath('-static'));

% Subset down to just those in Matlab
% Optionally subset to jarext (third-party jars)

tf = strncmp(p, matlabroot, numel(matlabroot));
p = p(tf);
%p = strrep(p, [matlabroot filesep], '');

doOnlyJarExt = true;
jarExtPath = strrep([matlabroot '/java/jarext'], '/', filesep);
if doOnlyJarExt
    p = p(strncmp(p, jarExtPath, numel(jarExtPath)));
end

isJarFile = ~cellfun('isempty', regexp(p, '\.jar$', 'once'));
jars = p(isJarFile);

attrsToList = {'Implementation-Version','Bundle-Name','Bundle-Version','Implementation-Name',};
for iJar = 1:numel(jars)
    jarPath = jars{iJar};
    md5 = file_md5hex(jarPath);
    shortName = strrep(jarPath, [matlabroot filesep 'java' filesep], '');
    fprintf('%-40s %s\n', shortName, md5);
    %fprintf('%s\n', shortName);
    jarFile = java.util.jar.JarFile(jarPath);
    manifest = jarFile.getManifest();
    if ~isempty(manifest)
        attrs = manifest.getMainAttributes();
        implementationVersion = char(attrs.getValue('Implementation-Version'));
        implementationName = char(attrs.getValue('Implementation-Name'));
        bundleVersion = char(attrs.getValue('Bundle-Version'));
        bundleName = char(attrs.getValue('Bundle-Name'));
        if ~isempty([implementationName implementationVersion bundleName bundleVersion])
            fprintf('%10s  %-20s  %1s  %-20s\n',...
                implementationVersion, implementationName,...
                bundleVersion, bundleName);
        end
    end
end

end

function out = file_md5hex(file)
fid = fopen(file, 'r');
fileRAII = onCleanup(@()fclose(fid));
data = fread(fid, 'int8');
out = char(org.apache.commons.codec.digest.DigestUtils.md5Hex(data));
end

function display_attrs(attrs)
attrsToSkip = {'Manifest-Version', 'Created-By', 'Ant-Version'};

%disp(attrs.keySet());
it = attrs.keySet().iterator();
while it.hasNext()
    key = it.next();
    if ismember(char(key), attrsToSkip)
        continue;
    end
    val = attrs.getValue(key);
    fprintf('%s: %s\n', char(key), char(val));
end

end

