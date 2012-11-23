#!/usr/bin/perl -w
# performance roll installation test.  Usage:
# performance.t [nodetype]
#   where nodetype is one of "Compute", "Dbnode", "Frontend" or "Login"
#   if not specified, the test assumes either Compute or Frontend

use Test::More qw(no_plan);

my $appliance = $#ARGV >= 0 ? $ARGV[0] :
                -d '/export/rocks/install' ? 'Frontend' : 'Compute';
my $installedOnAppliancesPattern = '.';
my %compilers = ('gnu' => 'gcc', 'intel' => 'icc', 'pgi' => 'pgcc');
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

  skip 'ipm not installed', 1 if ! -d $packageHome;
  fail('Need to write ipm test');
  open(OUT, ">$TESTFILE.sh");
  print OUT <<END;
if test -f /etc/profile.d/modules.sh; then
  . /etc/profile.d/modules.sh
  module load ROLLCOMPILER ROLLMPI_ROLLNETWORK ipm
fi
END
  close(OUT);
  $output = `/bin/bash $TESTFILE.sh`;
  ok($output =~ /./, 'ipm sample run');

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

  open(OUT, ">$TESTFILE-mxml.sh");
  print OUT <<END;
if test -f /etc/profile.d/modules.sh; then
  . /etc/profile.d/modules.sh
  module load ROLLCOMPILER ROLLMPI_ROLLNETWORK mxml
fi
$compilers{"ROLLCOMPILER"} -I\$MXML_BASE/include -o $TESTFILE-mxml.exe $TESTFILE-mxml.c -L\$MXML_BASE/lib -lmxml -lpthread
./$TESTFILE-mxml.exe
END
  close(OUT);
  $output = `/bin/bash $TESTFILE-mxml.sh`;
  ok($output =~ /node count is 3/, 'mxml sample run');

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

  for(i = 0; i < INDEX; i++) {
    for(j = 0; j < INDEX; j++) {
      mresult[i][j] = 0.0;
      matrixa[i][j] = matrixb[i][j] = rand() * (float)1.1;
    }
  }

  if(PAPI_flops(&real_time, &proc_time, &flpins, &mflops) < PAPI_OK)
    exit(1);

  for(i = 0; i < INDEX; i++)
    for(j = 0; j < INDEX; j++)
      for(k = 0; k < INDEX; k++)
        mresult[i][j] += matrixa[i][k] * matrixb[k][j];

  if(PAPI_flops(&real_time, &proc_time, &flpins, &mflops) < PAPI_OK)
    exit(2);

  printf("Real_time: %f\\nProc_time: %f\\nTotal flpins: %lld\\nMFLOPS: %f\\n",
  real_time, proc_time, flpins, mflops);
  PAPI_shutdown();
  return 0;

}
END
close(OUT);

  open(OUT, ">$TESTFILE.sh");
  print OUT <<END;
if test -f /etc/profile.d/modules.sh; then
  . /etc/profile.d/modules.sh
  module load ROLLCOMPILER ROLLMPI_ROLLNETWORK papi
fi
  $compilers{"ROLLCOMPILER"} -I\$PAPIHOME/include -o $TESTFILE-papi.exe $TESTFILE-papi.c -L\$PAPIHOME/lib -lpapi
  ./$TESTFILE-papi.exe
END

  close(OUT);
  $output = `/bin/bash $TESTFILE.sh`;
  ok($output =~ /MFLOPS:\s*\d+/, 'papi sample run');

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

  open(OUT, ">$TESTFILE-pdt.sh");
  print OUT <<END;
if test -f /etc/profile.d/modules.sh; then
  . /etc/profile.d/modules.sh
  module load ROLLCOMPILER ROLLMPI_ROLLNETWORK pdt
fi
cparse $TESTFILE-pdt.c
cat $TESTFILE-pdt.pdb
END
  close(OUT);
  $output = `/bin/bash $TESTFILE-pdt.sh`;
  ok($output =~ /stdout/, 'pdt sample run');

}

# tau
$packageHome = '/opt/tau';
$testDir = "$packageHome/test";
SKIP: {

  skip 'tau not installed', 1 if ! -d $packageHome;
  fail('Need to write tau test');
  open(OUT, ">$TESTFILE.sh");
  print OUT <<END;
if test -f /etc/profile.d/modules.sh; then
  . /etc/profile.d/modules.sh
  module load ROLLCOMPILER ROLLMPI_ROLLNETWORK tau
fi
END
  close(OUT);
  $output = `/bin/bash $TESTFILE.sh`;
  ok($output =~ /./, 'tau sample run');

}

SKIP: {

  skip 'performance not installed', 1
    if $appliance !~ /$installedOnAppliancesPattern/;
  skip 'modules not installed', 1 if ! -f '/etc/profile.d/modules.sh';
  foreach my $package(@packages) {
    `/bin/ls /opt/modulefiles/applications/.ROLLCOMPILER/$package/[0-9]* 2>&1`;
    ok($? == 0, "$package module installed");
    `/bin/ls /opt/modulefiles/applications/.ROLLCOMPILER/$package/.version.[0-9]* 2>&1`;
    ok($? == 0, "$package version module installed");
    ok(-l "/opt/modulefiles/applications/.ROLLCOMPILER/$package/.version",
       "$package version module link created");
  }

}

#`rm -fr $TESTFILE*`;
