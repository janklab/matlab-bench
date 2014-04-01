function out = list_java_lib_versions()
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

doOnlyJarExt = true;
% { sourceName, libNameField, libVersionField; ... }
sourcePrecedence = {
    'Maven'     'mvnArtifactId' 'mvnVersion'
    'MF-Impl'   'mfImplName'    'mfImplVersion'
    'MF-Bundle' 'mfBundleName'  'mfBundleVersion'
    };

p = sort(javaclasspath('-static'));

% Subset down to just those in Matlab
% Optionally subset to jarext (third-party jars)

tf = strncmp(p, matlabroot, numel(matlabroot));
p = p(tf);

jarExtPath = strrep([matlabroot '/java/jarext'], '/', filesep);
if doOnlyJarExt
    p = p(strncmp(p, jarExtPath, numel(jarExtPath)));
end

isJarFile = ~cellfun('isempty', regexp(p, '\.jar$', 'once'));
jars = p(isJarFile);

for iJar = 1:numel(jars)
    jarPath = jars{iJar};
    shortName = strrep(jarPath, [matlabroot filesep 'java' filesep], '');
    
    % Detect files based on hash values
    hashes = compute_file_hashes(jarPath);
    %fprintf('%-45s %s  %s\n', shortName, hashes.md5, hashes.sha1);
    
    mvnInfo = lookup_in_sonatype_repository(hashes.sha1);
%     if mvnInfo.hasInfo
%         fprintf('REPO:  %-20s  %-20s  %10s\n', mvnInfo.groupId, mvnInfo.artifactId, mvnInfo.version);
%     end
    
    % TODO: Check against our own list of known jar file digests
    
    % Get self-declared info from the JAR's manifest
    mfInfo = read_manifest_info(jarPath);
%     if mfInfo.hasInfo
%         fprintf('MF: %10s  %-20s  %1s  %-20s\n', mfInfo.implVersion, mfInfo.implName,...
%             mfInfo.bundleVersion, mfInfo.bundleName);
%     end
    
    % Assemble combined structure
    s.shortName = shortName;
    [~,fileName,fileExt] = fileparts(jarPath);
    s.fileName = [fileName fileExt];
    s.jarPath = jars{iJar};
    s.md5 = hashes.md5;
    s.sha1 = hashes.sha1;
    s.mvnGroupId = mvnInfo.groupId;
    s.mvnArtifactId = mvnInfo.artifactId;
    s.mvnVersion = mvnInfo.version;
    s.mfImplVersion = mfInfo.implVersion;
    s.mfImplName = mfInfo.implName;
    s.mfBundleVersion = mfInfo.bundleVersion;
    s.mfBundleName = mfInfo.bundleName;
    
    % Merge info from multiple sources
    s.libName = '';
    s.libVersion = '';
    s.infoSource = '';
    for iSource = 1:size(sourcePrecedence,1)
        [sourceName, nameField, versionField] = sourcePrecedence{iSource,:};
        if ~isempty(s.(nameField))
            s.libName = s.(nameField);
            s.libVersion = s.(versionField);
            s.infoSource = sourceName;
            break;
        end
    end
    
    records(iJar) = s; %#ok
end

% Convert to a sloppy but readable table
tbl.data = struct2cell(records(:))';
tbl.colnames = fieldnames(records);

out = tbl;

% TODO: Presentation format

% TODO: Condense per-jar results to per-library

end

function out = pullupfields(s, fields)
%PULLUPFIELDS Reorder named fields to front of structure
out = orderfields(s, [fields setdiff(fieldnames(s), fields, 'stable')]);
end

function out = read_manifest_info(jarFile)

out.hasInfo = false;
out.implName = '';
out.implVersion = '';
out.bundleName = '';
out.bundleVersion = '';

jJarFile = java.util.jar.JarFile(jarFile);
manifest = jJarFile.getManifest();
if ~isempty(manifest)
    attrs = manifest.getMainAttributes();
    out.implName = char(attrs.getValue('Implementation-Title'));
    out.implVersion = char(attrs.getValue('Implementation-Version'));
    out.bundleName = char(attrs.getValue('Bundle-Name'));
    out.bundleVersion = char(attrs.getValue('Bundle-Version'));
    out.hasInfo = ~isempty([out.implName out.implVersion out.bundleName out.bundleVersion]);
end

end

function out = compute_file_hashes(file)
%COMPUTE_FILE_HASHES Compute hashes (message digests) for a file's contents

fid = fopen(file, 'r');
data = fread(fid, 'int8');
fclose(fid);

out.md5 = compute_hash(data, 'MD5');
out.sha1 = compute_hash(data, 'SHA1');
end

function out = compute_hash(data, algorithm)
%COMPUTE_HASH Compute hash on given data
% data needs to be int8
digest = java.security.MessageDigest.getInstance(algorithm);
digestBytes = digest.digest(data);
formatter = javax.xml.bind.annotation.adapters.HexBinaryAdapter();
out = lower(char(formatter.marshal(digestBytes)));
end

function out = lookup_in_sonatype_repository(sha)
persistent hasWarned
if isempty(hasWarned);  hasWarned = false; end

out.hasInfo = 0;
out.groupId = '';
out.artifactId = '';
out.version = '';

queryBaseUrl = 'https://repository.sonatype.org/service/local/lucene/search';
queryUrl = sprintf('%s?sha1=%s', queryBaseUrl, lower(sha));
[response,status] = urlread(queryUrl);
if ~status && ~hasWarned
    warning('Failed doing lookup on Sonatype repository at %s', queryUrl);
    warning('Sonatype repo info may be unavailable for other items as well');
    hasWarned = true;
end

% Parse response
xmlSource = org.xml.sax.InputSource(java.io.StringReader(response));
doc = xmlread(xmlSource);
artifactNodes = doc.getElementsByTagName('artifact');
if artifactNodes.getLength() > 0
    % Assume first item has the relevant info
    out.hasInfo = 1;
    node = artifactNodes.item(0);
    out.groupId = char(node.getElementsByTagName('groupId').item(0).getTextContent());
    out.artifactId = char(node.getElementsByTagName('artifactId').item(0).getTextContent());
    out.version = char(node.getElementsByTagName('version').item(0).getTextContent());
end
end

function display_attrs(attrs)
%DISPLAY_ATTRS Display some manifest attributes
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

