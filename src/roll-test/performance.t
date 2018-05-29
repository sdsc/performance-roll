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

  open(OUT, ">$TESTFILE-papi.c");
  print OUT <<'END';
/* 
* File:    multiplex1_pthreads.c
* Author:  Rick Kufrin
*          rkufrin@ncsa.uiuc.edu                    
* Mods:    Philip Mucci
*          mucci@cs.utk.edu
*/

/* This file really bangs on the multiplex pthread functionality */

#include <pthread.h>
#include "papi_test.h"

int *events;
int numevents = 0;
int max_events=0;

double
loop( long n )
{
   long i;
   double a = 0.0012;

   for ( i = 0; i < n; i++ ) {
      a += 0.01;
   }
   return a;
}

void *
thread( void *arg )
{
   ( void ) arg; /*unused */
   int eventset = PAPI_NULL;
   long long *values;

   int ret = PAPI_register_thread(  );
   if ( ret != PAPI_OK )
      test_fail( __FILE__, __LINE__, "PAPI_register_thread", ret );
   ret = PAPI_create_eventset( &eventset );
   if ( ret != PAPI_OK )
      test_fail( __FILE__, __LINE__, "PAPI_create_eventset", ret );

   values=calloc(max_events,sizeof(long long));

   printf( "Event set %d created\n", eventset );

/* In Component PAPI, EventSets must be assigned a component index
   before you can fiddle with their internals.
   0 is always the cpu component */
   ret = PAPI_assign_eventset_component( eventset, 0 );
   if ( ret != PAPI_OK ) {
      test_fail( __FILE__, __LINE__, "PAPI_assign_eventset_component", ret );
   }

   ret = PAPI_set_multiplex( eventset );
   if ( ret == PAPI_ENOSUPP) {
       test_skip( __FILE__, __LINE__, "Multiplexing not supported", 1 );
   }
   else if ( ret != PAPI_OK ) {
       test_fail( __FILE__, __LINE__, "PAPI_set_multiplex", ret );
   }

   ret = PAPI_add_events( eventset, events, numevents );
   if ( ret < PAPI_OK ) {
      test_fail( __FILE__, __LINE__, "PAPI_add_events", ret );
   }

   ret = PAPI_start( eventset );
   if ( ret != PAPI_OK ) {
      test_fail( __FILE__, __LINE__, "PAPI_start", ret );
   }

   do_stuff(  );

   ret = PAPI_stop( eventset, values );
   if ( ret != PAPI_OK ) {
      test_fail( __FILE__, __LINE__, "PAPI_stop", ret );
   }

   ret = PAPI_cleanup_eventset( eventset );
   if ( ret != PAPI_OK ) {
      test_fail( __FILE__, __LINE__, "PAPI_cleanup_eventset", ret );
   }

   ret = PAPI_destroy_eventset( &eventset );
   if ( ret != PAPI_OK ) {
      test_fail( __FILE__, __LINE__, "PAPI_destroy_eventset", ret );
   }

   ret = PAPI_unregister_thread(  );
   if ( ret != PAPI_OK )
      test_fail( __FILE__, __LINE__, "PAPI_unregister_thread", ret );
   return ( NULL );
}

int
main( int argc, char **argv )
{
	int nthreads = 8, ret, i;
	PAPI_event_info_t info;
	pthread_t *threads;
	const PAPI_hw_info_t *hw_info;

	tests_quiet( argc, argv );	/* Set TESTS_QUIET variable */

	if ( !TESTS_QUIET ) {
		if ( argc > 1 ) {
			int tmp = atoi( argv[1] );
			if ( tmp >= 1 )
				nthreads = tmp;
		}
	}

	ret = PAPI_library_init( PAPI_VER_CURRENT );
	if ( ret != PAPI_VER_CURRENT ) {
		test_fail( __FILE__, __LINE__, "PAPI_library_init", ret );
	}

	hw_info = PAPI_get_hardware_info(  );
	if ( hw_info == NULL )
		test_fail( __FILE__, __LINE__, "PAPI_get_hardware_info", 2 );

	if ( strcmp( hw_info->model_string, "POWER6" ) == 0 ) {
		ret = PAPI_set_domain( PAPI_DOM_ALL );
		if ( ret != PAPI_OK ) {
			test_fail( __FILE__, __LINE__, "PAPI_set_domain", ret );
		}
	}

	ret = PAPI_thread_init( ( unsigned long ( * )( void ) ) pthread_self );
	if ( ret != PAPI_OK ) {
		test_fail( __FILE__, __LINE__, "PAPI_thread_init", ret );
	}

	ret = PAPI_multiplex_init(  );
	if ( ret != PAPI_OK ) {
		test_fail( __FILE__, __LINE__, "PAPI_multiplex_init", ret );
	}

	if ((max_events = PAPI_get_cmp_opt(PAPI_MAX_MPX_CTRS,NULL,0)) <= 0) {
		test_fail( __FILE__, __LINE__, "PAPI_get_cmp_opt", max_events );
	}

	if ((events = calloc(max_events,sizeof(int))) == NULL) {
		test_fail( __FILE__, __LINE__, "calloc", PAPI_ESYS );
	}

	/* Fill up the event set with as many non-derived events as we can */

	i = PAPI_PRESET_MASK;
	do {
		if ( PAPI_get_event_info( i, &info ) == PAPI_OK ) {
			if ( info.count == 1 ) {
				events[numevents++] = ( int ) info.event_code;
				printf( "Added %s\n", info.symbol );
			} else {
				printf( "Skipping derived event %s\n", info.symbol );
			}
		}
	} while ( ( PAPI_enum_event( &i, PAPI_PRESET_ENUM_AVAIL ) == PAPI_OK )
			  && ( numevents < max_events ) );

	printf( "Found %d events\n", numevents );

	do_stuff(  );

	printf( "Creating %d threads:\n", nthreads );

	threads =
		( pthread_t * ) malloc( ( size_t ) nthreads * sizeof ( pthread_t ) );
	if ( threads == NULL ) {
		test_fail( __FILE__, __LINE__, "malloc", PAPI_ENOMEM );
	}

	/* Create the threads */
	for ( i = 0; i < nthreads; i++ ) {
		ret = pthread_create( &threads[i], NULL, thread, NULL );
		if ( ret != 0 ) {
			test_fail( __FILE__, __LINE__, "pthread_create", PAPI_ESYS );
		}
	}

	/* Wait for thread completion */
	for ( i = 0; i < nthreads; i++ ) {
		ret = pthread_join( threads[i], NULL );
		if ( ret != 0 ) {
			test_fail( __FILE__, __LINE__, "pthread_join", PAPI_ESYS );
		}
	}

	printf( "Done." );
	test_pass( __FILE__, NULL, 0 );
	pthread_exit( NULL );
	exit( 0 );
}
END
close(OUT);

foreach my $compiler (@COMPILERS) {
  open(OUT, ">$TESTFILE.sh");
  print OUT <<END;
module unload intel
module load $compiler papi
$CC{$compiler} -I\$PAPIHOME/include -o $TESTFILE-papi.exe $TESTFILE-papi.c -L\$PAPIHOME/lib -lpapi -ltestlib -pthread
./$TESTFILE-papi.exe
END

  close(OUT);
  $output = `/bin/bash $TESTFILE.sh 2>&1`;
  like($output, qr/PASSED/, "papi sample run for the $compiler compiler");
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
