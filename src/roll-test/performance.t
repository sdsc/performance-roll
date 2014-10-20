#!/usr/bin/perl -w
# performance roll installation test.  Usage:
# performance.t [nodetype]
#   where nodetype is one of "Compute", "Dbnode", "Frontend" or "Login"
#   if not specified, the test assumes either Compute or Frontend

use Test::More qw(no_plan);

my $appliance = $#ARGV >= 0 ? $ARGV[0] :
                -d '/export/rocks/install' ? 'Frontend' : 'Compute';
my $installedOnAppliancesPattern = '.';
my @COMPILERS = split(/\s+/, 'ROLLCOMPILER');
my @MPIS = split(/\s+/, 'ROLLMPI');
my %CC = ('gnu' => 'gcc', 'intel' => 'icc', 'pgi' => 'pgcc');
my %CXX = ('gnu' => 'g++', 'intel' => 'icpc', 'pgi' => 'pgCC');
my @packages = ('ipm', 'mxml', 'papi', 'pdt', 'tau');
my $output;
my $TESTFILE = 'tmpperformance';

# performance-common.xml
foreach my $package(@packages) {
  if($appliance =~ /$installedOnAppliancesPattern/) {
    ok(-d "/opt/$package", "$package installed");
  } else {
    ok(! -d "/opt/$package", "$package not installed");
  }
}

# ipm
my $packageHome = '/opt/ipm';
my $testDir = "$packageHome/test";
SKIP: {

  skip 'ipm not installed', 2 if ! -d $packageHome;

  open(OUT, ">$TESTFILE-ipm.c");
  print OUT <<END;
#include <stdio.h>
#include <mpi.h>

int main (int argc, char **argv) {
  int rank, size;
  MPI_Init(&argc, &argv);
  MPI_Comm_rank(MPI_COMM_WORLD, &rank);
  MPI_Comm_size(MPI_COMM_WORLD, &size);
  printf("Hello from process %d of %d\\n", rank, size);
  MPI_Finalize();
  return 0;
}
END
close(OUT);
foreach my $compiler (@COMPILERS) {
  foreach my $mpi (@MPIS) {
    open(OUT, ">$TESTFILE-ipm.sh");
    print OUT <<END;
module load $compiler $mpi ipm
mkdir $TESTFILE-ipm.dir
cd $TESTFILE-ipm.dir
mpicc ../$TESTFILE-ipm.c -L\$IPMHOME/lib -lipm -L\$PAPIHOME/lib -lpapi
mpirun -np 4 ./a.out
END
    close(OUT);
    $output = `/bin/bash $TESTFILE-ipm.sh 2>&1`;
    like($output, qr/process 3/, "ipm sample run with $compiler $mpi");
    like($output, qr/wallclock\s*:\s*\d+/, 'ipm sample output');
    `rm -rf $TESTFILE-ipm.dir $TESTFILE-ipm.sh`;
  }
}

}

# mxml
$packageHome = '/opt/mxml';
SKIP: {

  skip 'mxml not installed', 1 if ! -d $packageHome;

  open(OUT, ">$TESTFILE-mxml.c");
  print OUT <<END;
#include <stdio.h>
#include <mxml.h>
int main(int argc, char **argv) {
  mxml_node_t *xml;
  mxml_node_t *node;
  int count = 0;
  xml = mxmlNewXML("1.0");
  node = mxmlNewElement(xml, "outer");
  node = mxmlNewElement(node, "inner");
  mxmlNewText(node, 0, "content");
  for (node = mxmlWalkNext(xml, xml, MXML_DESCEND);
       node != NULL;
       node = mxmlWalkNext(node, xml, MXML_DESCEND)) {
    count++;
  }
  printf("Total node count is %d\\n", count);
  return 0;
}
END
close(OUT);

foreach my $compiler (@COMPILERS) {
  open(OUT, ">$TESTFILE-mxml.sh");
  print OUT <<END;
module load $compiler mxml;
$CC{$compiler} -I\$MXML_BASE/include -o $TESTFILE-mxml.exe $TESTFILE-mxml.c -L\$MXML_BASE/lib -lmxml -lpthread
./$TESTFILE-mxml.exe
END
  close(OUT);
  $output = `/bin/bash $TESTFILE-mxml.sh 2>&1`;
  like($output, qr/node count is 3/, "mxml sample run for the $compiler compiler");
  `rm -f $TESTFILE-mxml.exe $TESTFILE-mxml.sh`;
}

}

# papi
$packageHome = '/opt/papi';
SKIP: {

  skip 'papi not installed', 1 if ! -d $packageHome;

  open(OUT, ">$TESTFILE-papi.c");
  print OUT <<END;
/* Adapted from http://web.eecs.utk.edu/~terpstra/using_papi/PAPI_flops.c */
#include <stdio.h>
#include <stdlib.h>
#include "papi.h"

#define INDEX 100

int main(int argc, char **argv) {

  float matrixa[INDEX][INDEX], matrixb[INDEX][INDEX], mresult[INDEX][INDEX];
  float real_time, proc_time, mflops;
  long long flpins;
  int i,j,k;
  int res;

  for(i = 0; i < INDEX; i++) {
    for(j = 0; j < INDEX; j++) {
      mresult[i][j] = 0.0;
      matrixa[i][j] = matrixb[i][j] = rand() * (float)1.1;
    }
  }

  res = PAPI_flops(&real_time, &proc_time, &flpins, &mflops);
  if(res < PAPI_OK) {
    printf("%s\\n", PAPI_strerror(res));
    exit(1);
  }

  for(i = 0; i < INDEX; i++)
    for(j = 0; j < INDEX; j++)
      for(k = 0; k < INDEX; k++)
        mresult[i][j] += matrixa[i][k] * matrixb[k][j];

  res = PAPI_flops(&real_time, &proc_time, &flpins, &mflops);
  if(res < PAPI_OK) {
    printf("%s\\n", PAPI_strerror(res));
    exit(2);
  }

  printf("Real_time: %f\\nProc_time: %f\\nTotal flpins: %lld\\nMFLOPS: %f\\n",
  real_time, proc_time, flpins, mflops);
  PAPI_shutdown();
  return 0;

}
END
close(OUT);

foreach my $compiler (@COMPILERS) {
  open(OUT, ">$TESTFILE.sh");
  print OUT <<END;
module load $compiler papi
$CC{$compiler} -I\$PAPIHOME/include -o $TESTFILE-papi.exe $TESTFILE-papi.c -L\$PAPIHOME/lib -lpapi
./$TESTFILE-papi.exe
END

  close(OUT);
  $output = `/bin/bash $TESTFILE.sh 2>&1`;
  like($output, qr/MFLOPS:\s*\d+/, "papi sample run for the $compiler compiler");
  `rm -f $TESTFILE-papi.exe $TESTFILE.sh`;
}

}

# pdt
$packageHome = '/opt/pdt';
SKIP: {

  skip 'pdt not installed', 1 if ! -d $packageHome;

  open(OUT, ">$TESTFILE-pdt.c");
  print OUT <<END;
#include <stdio.h>
int main(int argc, char **argv) {
  printf("Hello %d\\n", 15);
  return 0;
}
END
close(OUT);

foreach my $compiler (@COMPILERS) {
  open(OUT, ">$TESTFILE-pdt.sh");
  print OUT <<END;
module load $compiler pdt
cparse $TESTFILE-pdt.c
cat $TESTFILE-pdt.pdb
END
  close(OUT);
  $output = `/bin/bash $TESTFILE-pdt.sh 2>&1`;
  like($output, qr/stdout/, "pdt sample run for the $compiler compiler");
  `rm -f $TESTFILE-pdt.pdb`;
}
}

# tau
$packageHome = '/opt/tau';
SKIP: {

  skip 'tau not installed', 1 if ! -d $packageHome;

foreach my $compiler (@COMPILERS) {
  foreach my $mpi (@MPIS) {
    open(OUT, ">$TESTFILE-tau.sh");
    print OUT <<END;
module load $compiler $mpi tau
mkdir $TESTFILE-tau.dir
cd $TESTFILE-tau.dir
cp -r \$TAU_BASE/examples/taucompiler/c/* .
export TAU_MAKEFILE=\$TAU_BASE/x86_64/lib/Makefile.tau-$CXX{$compiler}-papi-mpi-pdt
make
mpirun -np 4 ./ring
END
    close(OUT);
    $output = `/bin/bash $TESTFILE-tau.sh 2>&1`;
    like($output, qr/3 done/, "tau sample run with $compiler $mpi");
    `rm -rf $TESTFILE-tau.dir $TESTFILE-tau.sh`;
  }
}

}

SKIP: {

  skip 'performance not installed', 1
    if $appliance !~ /$installedOnAppliancesPattern/;
  foreach my $package(@packages) {
     foreach my $compiler (@COMPILERS) {
       `/bin/ls /opt/modulefiles/applications/.${compiler}/$package/[0-9]* 2>&1`;
       ok($? == 0, "$package module installed for the $compiler compiler");
       `/bin/ls /opt/modulefiles/applications/.${compiler}/$package/.version.[0-9]* 2>&1`;
       ok($? == 0, "$package version module installed for the $compiler compiler");
       ok(-l "/opt/modulefiles/applications/.${compiler}/$package/.version",
       "$package version module link created for the $compiler compiler");
     }
  }
}

`rm -fr $TESTFILE*`;
