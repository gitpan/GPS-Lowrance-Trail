
# Sample utility demonstrating the use of GPS::Lowrance::Trail

# Converts a Longitude/Latitude file to a GDM16 file

use strict;

use GPS::Lowrance::Trail;
use FileHandle;

my $fin = new FileHandle shift;

unless (defined $fin) {
  die "Usage: $0 infile outfile\n";
}

my $fout = new FileHandle ("> " . (shift || "gdm16.txt"));

unless (defined $fout) {
  die "Unable to open output file\n";
}

my $trail = new GPS::Lowrance::Trail;

$trail->read_lonlat( $fin );

if ($trail->errors)
  {
    warn "There were errors reading the file\n";
  }
$trail->write_gdm16( $fout );

$fin->close;
$fout->close;
