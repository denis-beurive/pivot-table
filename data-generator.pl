# This script generates sample data that can be used as input to explore pivot tables.
#
# Use: perl data-generator.pl --date-from=20150312 --date-to=20160101 --max-employees=2 --max-categories=2
#      or just:
#      perl data-generator.pl
#
# The script will generate 2 files:
#
#     - The file "data.csv". This file contains data that can be loaded into the spreadsheet.
#     - The file "data.sql". This file contains SQL requests that can be send to a MySql server.
#
# CSV data:
#
#     Date;Total;Sales;cb;check;Category;Region;Employee;Chief
#     01/01/2014;8793;27;94;6;Sport;south;Adrian;Denis
#     01/01/2014;7140;5;35;65;Kitchen;south;Adrian;Denis
#     01/01/2014;6346;30;86;14;Phone;south;Adrian;Denis
#     01/01/2014;3362;3;19;81;Garden;south;Adrian;Denis
#
# With:
#
#     Date: day of the year.
#     Total: total of sales.
#     Sales: Number of sales.
#     Cb: pourcentage of sales done using a credit card.
#     Check: pourcentage of sales done using a check.
#     Category: Kitchen, Sport...
#     Region: north, south...
#     Employee: name of the employee.
#     Chief: name of the employee's chief.

use strict;
use warnings;
use DateTime;
use DateTime::Duration;
use Getopt::Long;

# -----------------------------------------------------------
# Configuration
# -----------------------------------------------------------

my %employees = (
	'north' => {
		'Arnaud' => ['Sacha', 'Agathe', 'Adam'],
		'Alice' => ['Jean-Pierre', 'Fabrice']
	},
	'south' => {
		'Denis' => ['Adrian', 'Agnes', 'Nathan', 'Gabriel']
	},
	'east' => {
		'Christophe' => ['Jules', 'Pierre', 'Jean'],
		'Mathieux' => ['Quan', 'Anna', 'Elisabeth']
	},
	'west' => {
		'Hervé' => ['Xavier', 'Christain', 'Marie', 'Julien']
	}
);

my @categories = ('Sport', 'Kitchen', 'Phone', 'Garden');
my $dateFrom = DateTime->new(year => 2015, month => 1, day => 1, time_zone => 'Europe/Paris');
my $dateTo = DateTime->new(year => 2015, month => 1, day => 30, time_zone => 'Europe/Paris');

# -----------------------------------------------------------
# Analyse de la ligne de commande
# -----------------------------------------------------------

my $optMaxEmployees  = -1;
my $optMaxCategories = -1;
my $optDateForm      = undef;
my $optDateTo        = undef;

my %options = (
	'max-employees=i'  => \$optMaxEmployees,
	'max-categories=i' => \$optMaxCategories,
	'date-from=s'      => \$optDateForm,
	'date-to=s'        => \$optDateTo
);

GetOptions(%options) or die("Invalide command line.\n");

if (defined($optDateForm)) {
	if ($optDateForm =~ m/^(\d{4})(\d{2})(\d{2})$/) {
		$dateFrom = DateTime->new(year => $1, month => $2, day => $3, time_zone => 'Europe/Paris');
	} else {
		die("Invalid start date: $optDateForm (should be YYYYMMDD)\n");
	}
}

if (defined($optDateTo)) {
	if ($optDateTo =~ m/^(\d{4})(\d{2})(\d{2})$/) {
		$dateTo = DateTime->new(year => $1, month => $2, day => $3, time_zone => 'Europe/Paris');
	} else {
		die("Invalid start date: $optDateTo (should be YYYYMMDD)\n");
	}
}

if (-1 ne $optMaxCategories) {
	if ($optMaxCategories <= $#categories) {
		splice(@categories, $optMaxCategories)
	}
}

if (-1 ne $optMaxEmployees) {
	foreach my $region (keys %employees) {
		foreach my $chief (keys $employees{$region}) {
			my @array = @{$employees{$region}->{$chief}};
			next if ($optMaxEmployees > $#array);
			splice(@array, $optMaxEmployees);
			$employees{$region}->{$chief} = \@array;
		}
	}	
}

print "Configuration:\n\n";
print "   Date from: " . $dateFrom->strftime('%d/%m/%Y') . "\n";
print "   Date to:   " . $dateTo->strftime('%d/%m/%Y') . "\n";
print "   Category: "  . join(', ', map{'"' . $_ . '"'} @categories) . "\n";

foreach my $region (keys %employees) {
	print "   ${region}:\n";
	foreach my $chief (keys $employees{$region}) {
		my @array = @{$employees{$region}->{$chief}};
		print "     - ${chief}: " . join(', ', @array) . "\n";
	}
}

print "\n";

# -----------------------------------------------------------
# Generate data
# -----------------------------------------------------------

my $cleaner = <<'END_MESSAGE';
SET foreign_key_checks = 0;
DELETE FROM region;
DELETE FROM chief;
DELETE FROM employee;
DELETE FROM category;
DELETE FROM sales;
SET foreign_key_checks = 1;
END_MESSAGE

# -----------------------------------------------------------
# Generate some data
# -----------------------------------------------------------

my @data = ();
my @sqls = ($cleaner);

### Generate the data for the spreadsheet and for the database.

foreach my $region (keys %employees) {
	push(@sqls, "INSERT INTO region SET name='${region}';");
}

foreach my $category (@categories) {
	push(@sqls, "INSERT INTO category SET name='${category}';");
}

foreach my $region (keys %employees) {
	push(@sqls, "SELECT id FROM region WHERE name='${region}' INTO \@regionId;");
	foreach my $chief (keys $employees{$region}) {
		push(@sqls, "INSERT INTO chief SET name='${chief}', fk_region=\@regionId;");
		foreach my $employee (@{$employees{$region}->{$chief}}) {
			push(@sqls, "SELECT id FROM chief WHERE name='${chief}' INTO \@chiefId;");
			push(@sqls, "INSERT INTO employee SET name='${employee}', fk_chief=\@chiefId;");
		}
	}
}

my $day = DateTime::Duration->new(days => 1);
push (@data, "Date;Total;Sales;Cb;Check;Category;Region;Employee;Chief");
do {
	my $date = $dateFrom->strftime('%d/%m/%Y');
	my $dateSql = $dateFrom->strftime('%Y-%m-%d');
	
	foreach my $region (keys %employees) {
		foreach my $chief (keys $employees{$region}) {
			foreach my $employee (@{$employees{$region}->{$chief}}) {
				push(@sqls, "SELECT id FROM employee WHERE name='${employee}' INTO \@employeeId;");
				foreach my $category (@categories) {
					push(@sqls, "SELECT id FROM category WHERE name='${category}' INTO \@categoryId;");
					my $salesNumber = int(rand(100));
					my $amountTotal = int(rand(10000));
					my $cb = int(rand(100));
					my $check = 100 - $cb;
					
					push(@sqls, "INSERT INTO sales SET `salesNumber`=$salesNumber, `dateSale`='${dateSql}', `totalSale`='${amountTotal}', `cb`='${cb}', `check`='${check}', `fk_employee`=\@employeeId, `fk_category`=\@categoryId;");
					push(@data, "$date;$amountTotal;$salesNumber;$cb;$check;$category;$region;$employee;$chief");
				}
			}
		}
	} 
	
	$dateFrom->add_duration($day);
} until (DateTime->compare($dateFrom, $dateTo) > 0);

### Save data into files.

my $fd;

open($fd, '>', 'data.sql') or die("Can not open file <data.sql>: $!");
print $fd join("\n", @sqls);
close($fd);

open($fd, '>', 'data.csv') or die("Can not open file <data.csv>: $!");
print $fd join("\n", @data);
close($fd);

