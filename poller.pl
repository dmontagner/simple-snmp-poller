#!/usr/bin/perl

#
# MIT License
# 
# Copyright (c) 2017 Diogo Luiz Montagner
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#  

use strict;
use warnings;

#
# Line format: 17|GET|interfaces.ifTable.ifEntry.ifType.49|vcp-0
#

# Function prototypes
sub DEBUG($);

my $DEBUG=0;

while(1) {

my $line="";
my $filename="";
my $idx=0; my $method=0; my $oid=0; my $description=0;
my $poll_results="";
my $system_command="";
my $router = "10.1.1.1";
my $sec=0; my $min=0; my $hour=0; my $day=0; my $mon=0; my $year_1900=0; my $wday=0; my $yday=0; my $isdst=0;
my $tmpline=""; my $tmpline1="";
my $poller_start=""; my $poller_finish="";
my $community = "public";

($sec,$min,$hour,$day,$mon,$year_1900,$wday,$yday,$isdst)=localtime;

$poller_start = "[" . $day . "/" . $mon . "]" . $hour . ":" . $min . ":" . $sec;

if ($ARGV[0] eq "") {
	print("\nERROR:\n\tOID DB required.\n\n");
	print("Usage:\n\t./poller.pl <OID_DB_FILE>\n\n");
	exit(-1);
}

if (!open(FILE, $ARGV[0])) {
	print("\nERROR:\n\terror opening file $ARGV[0]\n\n");
	exit(-1);
}

open(LOG, ">>perl_snmp_poller.log");

print("\nPolling cycle started at $poller_start\n");
print LOG "\nPolling cycle started at $poller_start\n";

while($line=<FILE>) {

	chomp($line);
	($idx, $method, $oid, $description) = split(/\|/,$line);
	$filename = "DB_IDX_" . $idx . ".POLLDB";
	open(DB, ">>$filename");

	if ($method eq "GET") {
		# using snmpget

		$system_command = "snmpget -c " . $community . " -v 1 " . $router . " " . $oid;

		$poll_results = qx($system_command);

		DEBUG("Results from the poller: -- $poll_results --");
		DEBUG("System command = $system_command");
		print DB "[$day/$mon]$hour:$min:$sec|$poll_results";
	}

	if ($method eq "BULK") {
		# using bulkget

		$system_command = "snmpbulkget -c " . $community . " -v2c " . $router . " " . $oid;

		$poll_results = qx($system_command);

		foreach $tmpline1 (split(/\n/, $poll_results)) {
			DEBUG("Results from the poller (line by line): -- $tmpline1 --");
			DEBUG("System command = $system_command");
			print DB "[$day/$mon]$hour:$min:$sec|$tmpline1\n";
		}

	}

	close(DB);
}

($sec,$min,$hour,$day,$mon,$year_1900,$wday,$yday,$isdst)=localtime;
$poller_finish = "[" . $day . "/" . $mon . "]" . $hour . ":" . $min . ":" . $sec;

print("\nPolling cycle finished at $poller_finish\n");
print LOG "\nPolling cycle finished at $poller_finish\n";

# waiting for the next polling cycle ( 30 seconds )

print("\nWaiting 30 seconds for the next polling cycle\n");
print LOG "\nWaiting 30 seconds for the next polling cycle\n";

close(LOG);

sleep(30);
} # end of the infinite loop

#####
#
# Sub-routines
#
######

sub DEBUG($) {
	
	my $debug_message = shift;
	chomp($debug_message);

	if ($DEBUG) {
		print("DEBUG: $debug_message\n");
	}
}
