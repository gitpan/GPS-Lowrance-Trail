
# Sample utility demonstrating the use of GPS::Lowrance::Trail

# Converts a Lowrance Trail exported from GDM16 to a Longitude/Latitude
# file which can be imported into other applications or GPSs.

use strict;

use GPS::Lowrance::Trail;
use FileHandle;

my $fin = new FileHandle shift;

unless (defined $fin) {
  die "Usage: $0 infile outfile\n";
}

my $fout = new FileHandle ("> " . (shift || "lonlat.txt"));

unless (defined $fout) {
  die "Unable to open output file\n";
}

my $trail = new GPS::Lowrance::Trail;

$trail->read_gdm16( $fin );

if ($trail->errors)
  {
    warn "There were errors reading the file\n";
  }

$trail->write_lonlat( $fout );

$fin->close;
$fout->close;
