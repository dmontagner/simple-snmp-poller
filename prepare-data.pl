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

sub prepare_data() {
	seek(DATA,0,0);
	my $data_description="";
	my $timestamp="";
	my $oid_result="";
	my $tmp1=""; my $tmp2=""; my $tmp3=""; my $tmp4="";

	my $fileout = $ARGV[1] . ".dat";

	open(DATA_OUT,">$fileout");

	while(my $data_line = <DATA>) {

		chomp($data_line);

		($timestamp, $oid_result) = split(/\|/,$data_line);
		($tmp1, $tmp2) = split(/\]/,$timestamp);
		$timestamp = $tmp2;
		resetTempVariables(2);
		($tmp1,$tmp2,$tmp3,$tmp4) = split(/\:/,$oid_result);
		$oid_result = $tmp4;
		
		($oid_number_read,$tmp2) = split(/\=/,$tmp3);

		resetTempVariables(4);

		my $tmp_oid_idx = $ARGV[1];
		($tmp1,$tmp2,$tmp3) = split(/\_/,$tmp_oid_idx);
		($tmp4,$tmp5) = split(/\./,$tmp3);
		$tmp_oid_idx = $tmp4;
		$data_description = findOIDDescription($tmp_oid_idx);
		resetTempVariables(5);

		print DATA_OUT "# Header\n#\n# DATA: $data_description\n";

		#
		# print the data in the gnuplot format
		#
		print DATA_OUT "$timestamp $oid_result"; print DATA_OUT "\n";
	}
	generateGnuPlotScriptFile($data_description,"Time",$data_description);
	$data_description="";
	print("\n\n");
}

sub findOIDDescription($) {
	my $oid_id = shift;
	my $oid_idx=""; 
	my $oid_method="";
	my $oid_number="";
	my $oid_description="";

	# rewind TOC
	seek(TOC,0,0);

	while(my $toc_line=<TOC>) {

		chomp($toc_line);

		($oid_idx,$oid_method,$oid_number,$oid_description) = split(/\|/,$toc_line);

		DEBUG("oid_id = $oid_id");
		DEBUG("oid_idx = $oid_idx");
		DEBUG("oid_method = $oid_method");
		DEBUG("oid_number = $oid_number");
		DEBUG("oid_description = $oid_description");
		DEBUG("toc_line = $toc_line");
		DEBUG("it will compare oid and oid_number");
		DEBUG("");

		if ($oid_id == $oid_idx) {
			DEBUG("returned!");
			return $oid_description;
		}
	}

	# if reaches here, return -1 (not found)
	return -1;
}

sub resetTempVariables($) {

	my $number = shift;

	if ($number == 1) {
		$tmp1="";
		return;
	}

	if ($number == 2) {
		$tmp1="";
		$tmp2="";
		return;
	}

	if ($number == 3) {
		$tmp1="";
		$tmp2="";
		$tmp3="";
		return;
	}

	if ($number == 4) {
		$tmp1="";
		$tmp2="";
		$tmp3="";
		$tmp4="";
		return;
	}

	if ($number == 5) {
		$tmp1="";
		$tmp2="";
		$tmp3="";
		$tmp4="";
		$tmp5="";
		return;
	}

	if ($number > 5) {
		$tmp1="";
		$tmp2="";
		$tmp3="";
		$tmp4="";
		$tmp5="";
		$tmp6="";
		$tmp7="";
		$tmp8="";
		$tmp9="";
		$tmp10="";
	}

}

sub generateGnuPlotScriptFile(%,%,%) {

	my $graph_title = shift;
	my $xtitle = shift;
	my $ytitle = shift;

	my $fileout = $ARGV[1] . ".gnuplot";
	open(PLOT,">$fileout");

	print PLOT "#!/opt/local/bin/gnuplot\n#\n";
	print PLOT "reset\n";
	print PLOT "set terminal png\n";
	print PLOT "\nset xdata time\n";
	print PLOT "set timefmt \"%H:%M:$S\"\n";
	print PLOT "set format x \"%H:%M\n";
	print PLOT "\nset xlabel \"$xtitle\"\n";
	print PLOT "\nset ylabel \"$ytitle\"\n";
	print PLOT "set yrange [0:100]\n";
	print PLOT "set title \"$graph_title\"\n";
	print PLOT "\nset grid\n\n";
	print PLOT "set style data linespoints\n";
	print PLOT "plot \"$ARGV[1].dat\" using 1:2 title \"$graph_title\" smooth bezier";
	print PLOT "\n";
}

sub DEBUG(%) {
	my $db_msg = shift;

	if ($DEBUG) {
		print("DEBUG: $db_msg\n");
	}
}

#
# Main part of the script
#
open(TOC,$ARGV[0]);
open(DATA, $ARGV[1]);

$DEBUG=0;

if ($#ARGV != 1) {
	print("\nERROR:\n\tInsufficient number of parameters!\n\nUsage:\n\t./prepare_data.pl <TOC_FILE> <DATA>\n\n");
	exit(-1);
}

prepare_data();
