java_lib_versions
==================

This is an attempt to programmatically determine which versions of which Java libraries are shipped with a given version of Matlab. Knowing those versions is relevant for development because the JARs for those libraries are all loaded in to Matlab's embedded JVM, and are exposed to your code. This means you can use objects from them, but may run in to compatibility issues if you want to use other versions, or other Java libraries with version-specific dependencies.

This code looks through all the files in $MATLABROOT/java/jarext and tries to identify them using a few different methods:

* Looking at the self-declared metadata in their META-INF/MANIFEST.MF file
* Comparing the file's digest against known JAR artifacts in the Maven Central Repository
* Comparing the file's digest against an internally-maintained list of known JAR checksums

## File digest databases

The hard part of this tool turns out to be getting a reference list of MD5/SHA1 digests for known libraries. Many newer open source libraries are published on the Maven Central Repository, and have a canonical binary JAR file, which makes looking them up easy. But older versions or projects aren't published there. And they may not even have a canonical binary JAR - that is, their distribution may not have a pre-built JAR file and you're expected to build your own from their source or class files. This means there may not be a single reference file to compare digests against.

The `custom_digest_map.csv` file that's part of this project contains digests for known libraries that were assembled by hand. For example, I found the `google-collect.jar` file inside the .zip file of the Google Collections 1.0 distribution. But I couldn't determine the ANTLR version in R2014a, maybe because older distributions of ANTLR are source-only.

Because of the lack of canonical JAR files to compare to, I think getting good coverage on this is probably a lost cause. The best that can be done for those releases is to deduce what version Matlab is using via other means, and then label that in the custom_digest_map using the MD5 for the file in Matlab's jarext/ dir.

Also, some of the libraries are closed source. For example, the JIDE library is a mix of open and closed source code. (And that's one that has compatibility problems if you want to use JIDE stuff yourself.) The open source stuff is available on GitHub, but its jide-oss JAR distribution doesn't match the jide-common JARs found in commercial users. And the Saxon 9 parser has open and closed source tiers, with no canonical binary available for older versions.


## Notes on particular libraries

Jini was transferred to Apache and renamed "River". The jini.org website is defunct and downloads for older distributions do not seem readily available. The Apache archive (http://archive.apache.org/dist/river/) starts at version 2.2.0.
 
Avalon:  Archived downloads going back to 2003 are available at http://archive.apache.org/dist/avalon/avalon-framework/jars/ but none of them match the avalon-framework.jar in R2014a. Maybe a custom MathWorks dist build?


 