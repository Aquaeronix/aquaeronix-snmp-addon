#!/usr/bin/perl -w
#
# snmp_persist_aquaero5.pl
#
# Export the Aquaero 5 sensor readings and settings provided ny Aquaeronix to net-snmp via 
# pass_persist for external consumption.
#
# Copyright 2013 JinTu <JinTu@praecogito.com>
# Copyright 2015 Barracks510 <barracks510@gmail.com>
#
#
# This file is a support utility of Aquaeronix.
#
# Copyright 2012 lynix <lynix47@gmail.com>
# Copyright 2013 JinTu <JinTu@praecogito.com>, lynix <lynix47@gmail.com>
# Copyright 2015 Barracks510 <barracks510@gmail.com>
#
# Aquaeronix is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Aquaeronix is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Aquaeronix. If not, see <http://www.gnu.org/licenses/>.
#
####

use strict;


#------------------------------------------------------------#
my $aeroclipath = "/usr/local/sbin/";
my $aeroclicmd = $aeroclipath . "aerocli -a -o export";

#my $debug = 1;
my $debug = 0;
my $cache_secs = 60;
my $mibtime = 0;

my ($mib,$oid_in,$oid,$found);

#------------------------------------------------------------#
# figure out what to send back

# Switch on autoflush
$| = 1;

my $baseoid = '.1.3.6.1.4.1.2021.255.65.67';


# Main loop
while (my $cmd = <STDIN>) {
	chomp $cmd;

	if ($cmd eq "PING") {
		print "PONG\n";
	} elsif ($cmd eq "get") {
		$oid_in = <STDIN>;

		$oid = get_oid($oid_in);
		$mib = create_mib(); 
 
 		if (defined($mib->{$oid})) {
			print "$baseoid.$oid\n";
			print $mib->{$oid}[0]."\n";
			print $mib->{$oid}[1]."\n";
		} else {
			print "NONE\n";
		}
	} elsif ($cmd eq "getnext") {
		$oid_in = <STDIN>;

		$oid = get_oid($oid_in);
		$mib = create_mib(); 
		$found = 0;

		my @s = sort { oidcmp($a, $b) } keys %{ $mib };
		for (my $i = 0; $i < @s; $i++) {
			if (oidcmp($oid, $s[$i]) == -1) {
				print "$baseoid.".$s[$i]."\n";
				print $mib->{$s[$i]}[0]."\n";
				print $mib->{$s[$i]}[1]."\n";
				$found = 1;
				last;
     			}
    		}
    
		if (!$found) {
			print "NONE\n";
		}
	} else {
  	# Unknown command
  	}
}

#------------------------------------------------------------#
# get all the sensor readings and settings
sub create_mib {
	my %tmpmib;

	if (time - $mibtime < $cache_secs) {
		# Just return the cached value
    		return $mib;
  	}
	my @aerocliout = `$aeroclicmd`;
 
	foreach my $line (@aerocliout) {
		chomp($line);
	
		# Sensor readings
		if ($line =~ /^TEMP\d+=/) {
			my ($tempnum,$tempval) = $line =~ /^TEMP(\d+)=(-?\d+\.\d+)/i;
			print "Line->$line<-\n" if $debug;
			$tempval = 0 if ($tempval < 0);
			print "Temp $tempnum = $tempval (" . strip_decimal($tempval) . ")\n" if $debug;
			$tmpmib{"1.1.2.1.0.$tempnum"} = [ "string", "Temp$tempnum" ];
			$tmpmib{"1.1.2.2.0.$tempnum"} = [ "gauge", adjust_to_32bit(strip_decimal($tempval)) ];
		} elsif ($line =~ /^FAN\d+_VRM_TEMP=/) {
			my ($fannum,$tempval) = $line =~ /^FAN(\d+)_VRM_TEMP=(-?\d+\.\d+)/i;
			print "Line->$line<-\n" if $debug;
			$tempval = 0 if ($tempval < 0);
			print "Fan $fannum VRM temp = $tempval (" . strip_decimal($tempval) . ")\n" if $debug;
			$tmpmib{"1.1.3.1.0.$fannum"} = [ "string", "Fan$fannum" ];
			$tmpmib{"1.1.3.2.0.$fannum"} = [ "gauge", adjust_to_32bit(strip_decimal($tempval)) ];
		} elsif ($line =~ /^FAN\d+_CURRENT=/) {
			my ($fannum,$currentval) = $line =~ /^FAN(\d+)_CURRENT=(\d+)/i;
			print "Line->$line<-\n" if $debug;
			print "Fan $fannum current = $currentval\n" if $debug;
			$tmpmib{"1.1.3.3.0.$fannum"} = [ "gauge", adjust_to_32bit($currentval) ];
		} elsif ($line =~ /^FAN\d+_RPM=/) {
			my ($fannum,$rpmval) = $line =~ /^FAN(\d+)_RPM=(\d+)/i;
			print "Line->$line<-\n" if $debug;
			print "Fan $fannum RPM = $rpmval\n" if $debug;
			$tmpmib{"1.1.3.4.0.$fannum"} = [ "gauge", adjust_to_32bit($rpmval) ];
		} elsif ($line =~ /^FAN\d+_DUTY_CYCLE=/) {
			my ($fannum,$dutycycleval) = $line =~ /^FAN(\d+)_DUTY_CYCLE=(\d+\.\d+)/i;
			print "Line->$line<-\n" if $debug;
			print "Fan $fannum duty cycle = $dutycycleval (" . strip_decimal($dutycycleval) . ")\n" if $debug;
			$tmpmib{"1.1.3.5.0.$fannum"} = [ "gauge", adjust_to_32bit(strip_decimal($dutycycleval)) ];
		} elsif ($line =~ /^FAN\d+_VOLTAGE=/) {
			my ($fannum,$voltageval) = $line =~ /^FAN(\d+)_VOLTAGE=(\d+\.\d+)/i;
			print "Line->$line<-\n" if $debug;
			print "Fan $fannum duty cycle = $voltageval (" . strip_decimal($voltageval) . ")\n" if $debug;
			$tmpmib{"1.1.3.6.0.$fannum"} = [ "gauge", adjust_to_32bit(strip_decimal($voltageval)) ];
		} elsif ($line =~ /^FLOW\d+=/) {
			my ($flownum,$flowval) = $line =~ /^FLOW(\d+)=(\d+\.\d+)/i;
			print "Line->$line<-\n" if $debug;
			print "Flow sensor $flownum = $flowval (" . strip_decimal($flowval) . ")\n" if $debug;
			$tmpmib{"1.1.4.1.0.$flownum"} = [ "string", "Flow$flownum" ];
			$tmpmib{"1.1.4.2.0.$flownum"} = [ "gauge", adjust_to_32bit(strip_decimal($flowval)) ];
		} elsif ($line =~ /^SYS_TEMP_CPU\d+=/) {
			my ($cpunum,$tempval) = $line =~ /^SYS_TEMP_CPU(\d+)=(\d+\.\d+)/i;
			print "Line->$line<-\n" if $debug;
			print "CPU $cpunum = $tempval (" . strip_decimal($tempval) . ")\n" if $debug;
			$tmpmib{"1.1.5.1.0.$cpunum"} = [ "string", "CPUTemp$cpunum" ];
			$tmpmib{"1.1.5.2.0.$cpunum"} = [ "gauge", adjust_to_32bit(strip_decimal($tempval)) ];
		} elsif ($line =~ /^LEVEL\d+=/) {
			my ($levelnum,$levelval) = $line =~ /^LEVEL(\d+)=(\d+\.\d+)/i;
			print "Line->$line<-\n" if $debug;
			print "Level sensor $levelnum = $levelval (" . strip_decimal($levelval) . ")\n" if $debug;
			$tmpmib{"1.1.6.1.0.$levelnum"} = [ "string", "Level$levelnum" ];
			$tmpmib{"1.1.6.2.0.$levelnum"} = [ "gauge", adjust_to_32bit(strip_decimal($levelval)) ];
		} elsif ($line =~ /^VIRT_TEMP\d+=/) {
			my ($tempnum,$tempval) = $line =~ /^VIRT_TEMP(\d+)=(-?\d+\.\d+)/i;
			print "Line->$line<-\n" if $debug;
			$tempval = 0 if ($tempval < 0);
			print "Virtual sensor temp $tempnum = $tempval (" . strip_decimal($tempval) . ")\n" if $debug;
			$tmpmib{"1.1.7.1.0.$tempnum"} = [ "string", "VirtualTemp$tempnum" ];
			$tmpmib{"1.1.7.2.0.$tempnum"} = [ "gauge", adjust_to_32bit(strip_decimal($tempval)) ];
		} elsif ($line =~ /^SOFT_TEMP\d+=/) {
			my ($tempnum,$tempval) = $line =~ /^SOFT_TEMP(\d+)=(-?\d+\.\d+)/i;
			print "Line->$line<-\n" if $debug;
			$tempval = 0 if ($tempval < 0);
			print "Software sensor temp $tempnum = $tempval (" . strip_decimal($tempval) . ")\n" if $debug;
			$tmpmib{"1.1.8.1.0.$tempnum"} = [ "string", "SoftwareTemp$tempnum" ];
			$tmpmib{"1.1.8.2.0.$tempnum"} = [ "gauge", adjust_to_32bit(strip_decimal($tempval)) ];
		} elsif ($line =~ /^OTHER_TEMP\d+=/) {
			my ($tempnum,$tempval) = $line =~ /^OTHER_TEMP(\d+)=(-?\d+\.\d+)/i;
			print "Line->$line<-\n" if $debug;
			$tempval = 0 if ($tempval < 0);
			print "Other sensor temp $tempnum = $tempval (" . strip_decimal($tempval) . ")\n" if $debug;
			$tmpmib{"1.1.9.1.0.$tempnum"} = [ "string", "OtherTemp$tempnum" ];
			$tmpmib{"1.1.9.2.0.$tempnum"} = [ "gauge", adjust_to_32bit(strip_decimal($tempval)) ];
		}
	}
	$mib = \%tmpmib;
	$mibtime = time;
	return $mib;
} 

# Strip the decimal place from floating point values
sub strip_decimal {
	my ($inval) = @_;
	if ($inval == 0.0) {
		return 0;
	} else {
		$inval =~ s/\.//;
 		return $inval;
	}
}

sub create_coid {
	my ($k, %p, %oids) = @_;
	my ($ifoid,$val) = split /\s/, $k;

	my $id = $p{$val};
	my $oid= "";

	while (defined($id)) {
		$oid = $oids{$id}?$oids{$id}++:1;
		print "$oid\n";
		$id = $p{$id};
	}
	
	return "";
}


sub adjust_to_32bit {
	my ($val) = @_;
	if ($val > 4294967295) {
		$val = $val % 4294967295;
	}
	return $val;
}

sub get_oid {
	my ($oid) = @_;
	chomp $oid;

	my $base = $baseoid;
	$base =~ s/\./\\./g;

	if ($oid !~ /^$base(\.|$)/) {
		# Requested oid doesn't match base oid
		return 0;
	}

	$oid =~ s/^$base\.?//;
	return $oid;
}


sub oidcmp {
	my ($x, $y) = @_;

	my @a = split /\./, $x;
	my @b = split /\./, $y;

	my $i = 0;

	while (1) {

		if ($i > $#a) {
			if ($i > $#b) {
				return 0;
      			} else {
				return -1;
      			}
		} elsif ($i > $#b) {
			return 1;
		}

		if ($a[$i] < $b[$i]) {
			return -1;
		} elsif ($a[$i] > $b[$i]) {
			return 1;
		}
		$i++;
	}
}

