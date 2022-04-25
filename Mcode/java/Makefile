# Makefile for matlab-bench's main custom Java code
#
# This is a stupid little special-purpose makefile. Don't use this as a model for
# anything else. For Java projects, you should use Ant or Maven instead of Make anyway.
#
# WARNING: You must run this using a Java 8 compiler! Otherwise you'll get too-new
# target class files that won't work under the Java 8 JVM shipped with Matlab
# (R2022a and older, at least).

.DEFAULT: build

# BUG: This is busted because it uses options only supported on newer post-8
# javac tools.
.PHONY: build
build:
	mkdir -p classes
	javac --source 8 --target 8 \
    -d classes --source-path src src/net/apjanke/matlab_bench/bench_nops/DummyJavaClass.java

# Hack to get it to build with Java 8 javac
.PHONY: build-8
build-8:
	mkdir -p classes
	javac -d classes src/net/apjanke/matlab_bench/bench_nops/*.java

.PHONY: rebuild-8
rebuild-8:
	make clean && make build-8 && make jar

.PHONY: jar
jar: classes
	rm *.jar
	cd classes; jar cf ../matlab-bench-internals.jar *

.PHONY: clean
clean:
	rm -rf classes
