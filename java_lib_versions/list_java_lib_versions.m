function out = list_java_lib_versions()
%LIST_JAVA_LIB_VERSIONS Lists versions of Java libraries in this Matlab
%
% This attempts to detect the versions of the Java libraries bundled with
% this version of Matlab.
%
% Thanks to https://github.com/armhold/Provenance for showing me how to do the Maven
% Central Repository queries.
%
% TODO: Add our own list of known JAR digests to cover those that aren't in Maven.
%
% Usage:
% x = list_java_lib_versions;
% java_lib_report(x);


doOnlyJarExt = true;
% { sourceName, libNameField, libVersionField; ... }
sourcePrecedence = {
    'Maven'     'mvnArtifactId' 'mvnVersion'
    'MF-Impl'   'mfImplName'    'mfImplVersion'
    'MF-Bundle' 'mfBundleName'  'mfBundleVersion'
    };


% Find JARs shipped with Matlab

% Only consider the jars in the Matlab installation itself.
% Optionally subset to just jarext (third-party jars). Internal MathWorks jars are
% unidentifiable, and not of interest anyway; we care about libraries we might want
% to use ourselves, or avoid compatibility problems with.

p = sort(javaclasspath('-static'));
tf = strncmp(p, matlabroot, numel(matlabroot));
p = p(tf);
jarExtPath = strrep([matlabroot '/java/jarext'], '/', filesep);
if doOnlyJarExt
    p = p(strncmp(p, jarExtPath, numel(jarExtPath)));
end
isJarFile = ~cellfun('isempty', regexp(p, '\.jar$', 'once'));
jars = p(isJarFile);

% Examine and identify each JAR
for iJar = 1:numel(jars)
    jarPath = jars{iJar};
    shortName = strrep(jarPath, [matlabroot filesep 'java' filesep], '');
    
    % Identify files based on hash values
    hashes = compute_file_hashes(jarPath);
    mvnInfo = lookup_in_sonatype_repository(hashes.sha1);
    
    % TODO: Check against our own list of known jar file digests
    
    % Get self-declared info from the JAR's manifest
    mfInfo = read_manifest_info(jarPath);
    
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
    s.thingName = '';
    s.libVersion = '';
    s.infoSource = '';
    for iSource = 1:size(sourcePrecedence,1)
        [sourceName, nameField, versionField] = sourcePrecedence{iSource,:};
        if ~isempty(s.(nameField))
            s.thingName = s.(nameField);
            s.libVersion = s.(versionField);
            s.infoSource = sourceName;
            break;
        end
    end
    s.libName = s.thingName;
    
    records(iJar) = s; %#ok
end

% Convert to a sloppy but readable table
records = pullupfields(records, {'fileName','shortName','libName','libVersion','infoSource'});
tbl = lametable(records);

% Condense per-jar results to per-library
% (This "library" notion is just a collection of JARs from one project, as defined by matlab-bench.)

% This is a hackish implementation of an SQL-style JOIN operation
libMap = read_map_csv_file('artifact_library_map.csv',3);
tbl = joinupdate(tbl, {'mvnGroupId','thingName'}, {'libName'}, libMap, {'libName'});

% Structure output as results and details
tfIDed = ~ strcmp(tbl.data(:,3), '');
out.identifiedLibs = distinct(project(restrict(tbl, tfIDed), {'libName','libVersion','infoSource'}));
out.unidentifiedJars = restrict(tbl, ~tfIDed);
out.details = tbl;
end

function out = pullupfields(s, fields)
%PULLUPFIELDS Reorder named fields to front of structure
out = orderfields(s, [fields setdiff(fieldnames(s)', fields, 'stable')]);
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


