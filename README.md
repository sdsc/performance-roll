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

The sdsc-roll must be installed on the build machine, since the build process
depends on make include files provided by that roll.

The roll sources assume that modulefiles provided by SDSC compiler and mpi
rolls are available, but it will build without them as long as the environment
variables they provide are otherwise defined.


## Building

To build the performance-roll, execute this on a Rocks development
machine (e.g., a frontend or development appliance):

```shell
% make 2>&1 | tee build.log
```

A successful build will create the file `performance-*.disk1.iso`.  If you built the
roll on a Rocks frontend, proceed to the installation step. If you built the
roll on a Rocks development appliance, you need to copy the roll to your Rocks
frontend before continuing with installation.

This roll source supports building with different compilers and for different
MPI flavors.  The `ROLLCOMPILER` and `ROLLMPI` make variables can be used to
specify the names of compiler and MPI modulefiles to use for building the
software, e.g.,

```shell
make ROLLCOMPILER=intel ROLLMPI=mvapich2_ib 2>&1 | tee build.log
```

The build process recognizes "gnu", "intel" or "pgi" as the value for the
`ROLLCOMPILER` variable; any MPI modulefile name may be used as the value of
the `ROLLMPI` variable.  The default values are "gnu" and "rocks-openmpi".


## Installation

To install, execute these instructions on a Rocks frontend:

```shell
% rocks add roll *.iso
% rocks enable roll performance
% cd /export/rocks/install
% rocks create distro
```

Subsequent installs of compute and login nodes will then include the contents
of the performance-roll.  To avoid cluttering the cluster frontend with unused
software, the performance-roll is configured to install only on compute and
login nodes. To force installation on your frontend, run this command after
adding the performance-roll to your distro

```shell
% rocks run roll performance host=NAME | bash
```

where NAME is the DNS name of a compute or login node in your cluster.

In addition to the software itself, the roll installs package environment
module files in:

```shell
/opt/modulefiles/applications/.(compiler)/(package)
```


## Testing

The performance-roll includes a test script which can be run to verify proper
installation of the roll documentation, binaries and module files. To
run the test scripts execute the following command(s):

```shell
% /root/rolltests/performance.t 
```
