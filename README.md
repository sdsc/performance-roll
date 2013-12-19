# SDSC "performance" roll

## Overview

This roll bundles a collection of performance measurement packages: IPM,
MXML, PAPI, PDT, and TAU.

For more information about the various packages included in the performance roll please visit their official web pages:

- <a href="http://ipm-hpc.sourceforge.net" target="_blank">IPM</a> is a portable
profiling infrastructure for parallel codes.
- <a href="http://www.minixml.org/" target="_blank">MXML</a> is a small XML
library that you can use to read and write XML and XML-like data files in your
application without requiring large non-standard libraries.
- <a href="http://icl.cs.utk.edu/papi/" target="_blank">PAPI</a> provides the
tool designer and application engineer with a consistent interface and
methodology for use of the performance counter hardware found in most major
microprocessors.
- <a href="http://www.cs.uoregon.edu/research/pdt/home.php"
target="_blank">PDT</a> is a framework for analyzing source code written in
several programming languages and for making rich program knowledge accessible
to developers of static and dynamic analysis tools.
- <a href="http://www.cs.uoregon.edu/research/tau/home.php"
target="_blank">TAU</a> is a portable profiling and tracing toolkit for
performance analysis of parallel programs written in Fortran, C, C++, Java,
Python.


## Requirements

To build/install this roll you must have root access to a Rocks development
machine (e.g., a frontend or development appliance).

If your Rocks development machine does *not* have Internet access you must
download the appropriate performance source file(s) using a machine that does
have Internet access and copy them into the `src/<package>` directories on your
Rocks development machine.


## Dependencies

Unknown at this time.


## Building

To build the performance-roll, execute these instructions on a Rocks development
machine (e.g., a frontend or development appliance):

```shell
% make default 2>&1 | tee build.log
% grep "RPM build error" build.log
```

If nothing is returned from the grep command then the roll should have been
created as... `performance-*.iso`. If you built the roll on a Rocks frontend then
proceed to the installation step. If you built the roll on a Rocks development
appliance you need to copy the roll to your Rocks frontend before continuing
with installation.

This roll source supports building with different compilers and for different
network fabrics and mpi flavors.  By default, it builds using the gnu compilers
for openmpi ethernet.  To build for a different configuration, use the
`ROLLCOMPILER`, `ROLLMPI` and `ROLLNETWORK` make variables, e.g.,

```shell
make ROLLCOMPILER=intel ROLLMPI=mpich2 ROLLNETWORK=mx 
```

The build process currently supports one or more of the values "intel", "pgi",
and "gnu" for the `ROLLCOMPILER` variable, defaulting to "gnu".  It supports
`ROLLMPI` values "openmpi", "mpich2", and "mvapich2", defaulting to "openmpi".
It uses any `ROLLNETWORK` variable value(s) to load appropriate mpi modules,
assuming that there are modules named `$(ROLLMPI)_$(ROLLNETWORK)` available
(e.g., `openmpi_ib`, `mpich2_mx`, etc.).

If the `ROLLCOMPILER`, `ROLLNETWORK` and/or `ROLLMPI` variables are specified,
their values are incorporated into the names of the produced roll and rpms, e.g.,

```shell
make ROLLCOMPILER=intel ROLLMPI=mvapich2 ROLLNETWORK=ib
```
produces a roll with a name that begins "`performance_intel_mvapich2_ib`"; it
contains and installs similarly-named rpms.


## Installation

To install, execute these instructions on a Rocks frontend:

```shell
% rocks add roll *.iso
% rocks enable roll performance
% cd /export/rocks/install
% rocks create distro
% rocks run roll performance | bash
```

In addition to the software itself, the roll installs performance environment
module files in:

```shell
/opt/modulefiles/applications/.(compiler)/performance
```


## Testing

The performance-roll includes a test script which can be run to verify proper
installation of the performance-roll documentation, binaries and module files. To
run the test scripts execute the following command(s):

```shell
% /root/rolltests/performance.t 
ok 1 - performance is installed
ok 2 - performance test run
ok 3 - performance module installed
ok 4 - performance version module installed
ok 5 - performance version module link created
1..5
```
