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
module unload intel
module load $compiler $mpi ipm
mkdir $TESTFILE-ipm.dir
cd $TESTFILE-ipm.dir
mpicc ../$TESTFILE-ipm.c -L\$IPMHOME/lib -lipm -L\$PAPIHOME/lib -lpapi -ldl
output=`mpirun -np 4 ./a.out 2>&1`
if [[ "\$output" =~ "run-as-root" ]]; then
  output=`mpirun --allow-run-as-root -np 4 ./a.out 2>&1`
fi
echo \$output
END
    close(OUT);
    $output = `/bin/bash $TESTFILE-ipm.sh 2>&1`;
    like($output, qr/process 3/, "ipm sample run with $compiler $mpi");
    like($output, qr/wallclock\s*:\s*\d+/, 'ipm sample output');
    `rm -rf $TESTFILE-ipm.dir $TESTFILE-ipm.sh`;
  }
  $output = `module load $compiler ipm; echo \$IPMHOME 2>&1`;
  my $firstmpi = $MPIS[0];
  $firstmpi =~ s#/.*##;
  like($output, qr#/opt/ipm/$compiler/$firstmpi#, 'ipm modulefile defaults to first mpi');
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
module unload intel
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

foreach my $compiler (@COMPILERS) {
  foreach my $mpi (@MPIS) {
  open(OUT, ">$TESTFILE.sh");
  print OUT <<END;
module unload intel
module load $compiler $mpi papi
$CC{$compiler} -I\$PAPIHOME/include -o $TESTFILE-papi.exe \$PAPIHOME/examples/PAPI_state.c -L\$PAPIHOME/lib -lpapi -pthread
./$TESTFILE-papi.exe
END

  close(OUT);
  $output = `/bin/bash $TESTFILE.sh 2>&1`;
  like($output, qr/Eventset is currently running /, "papi sample run for the $compiler compiler and $mpi");
  `rm -f $TESTFILE-papi.exe $TESTFILE.sh`;
}
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
module unload intel
module load $compiler $mpi tau
mkdir $TESTFILE-tau.dir
cd $TESTFILE-tau.dir
cp -r \$TAU_BASE/examples/taucompiler/c/* .
if test "$compiler" = "gnu"; then
  export TAU_MAKEFILE=\$TAU_BASE/x86_64/lib/Makefile.tau-papi-mpi-pdt
else
  export TAU_MAKEFILE=\$TAU_BASE/x86_64/lib/Makefile.tau-$CXX{$compiler}-papi-mpi-pdt
fi
if test -n "\$TAU_OPTIONS"; then
  export TAU_OPTIONS="\$TAU_OPTIONS -optRevert"
else
  export TAU_OPTIONS="-optRevert"
fi
make
output=`mpirun -np 4 ./ring 2>&1`
if [[ "\$output" =~ "run-as-root" ]]; then
  output=`mpirun --allow-run-as-root -np 4 ./ring 2>&1`
fi
echo "\$output"
END
    close(OUT);
    $output = `/bin/bash $TESTFILE-tau.sh 2>&1`;
    like($output, qr/3 done/, "tau sample run with $compiler $mpi");
    `rm -rf $TESTFILE-tau.dir $TESTFILE-tau.sh`;
  }
  $output = `module load $compiler tau; echo \$TAUHOME 2>&1`;
  my $firstmpi = $MPIS[0];
  $firstmpi =~ s#/.*##;
  like($output, qr#/opt/tau/$compiler/$firstmpi#, 'tau modulefile defaults to first mpi');
}

}

SKIP: {

  skip 'performance not installed', 1
    if $appliance !~ /$installedOnAppliancesPattern/;
  foreach my $package(@packages) {
    `/bin/ls /opt/modulefiles/applications/$package/[0-9]* 2>&1`;
    ok($? == 0, "$package module installed");
    `/bin/ls /opt/modulefiles/applications/$package/.version.[0-9]* 2>&1`;
    ok($? == 0, "$package version module installed");
    ok(-l "/opt/modulefiles/applications/$package/.version",
    "$package version module link created");
  }
}

`rm -fr $TESTFILE*`;
