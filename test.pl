
use Test;
BEGIN { plan tests => 8 };
use GPS::Lowrance::Trail 0.41;
ok(1);

my $trail = new GPS::Lowrance::Trail( rounding => 0 );
ok(defined $trail);

ok( !$trail->rounding );

$trail->rounding(1);
ok( $trail->rounding );

ok( $trail->size == 0 );

$trail->add_point(0,0);
ok( $trail->size == 1 );

my $ref = $trail->get_trail();

ok( ref($ref) eq "ARRAY" );
ok( @$ref == $trail->size );

# We need to test the conversions, although rounding errors could be
# problematic.

__END__

use FileHandle;


my $fh = new FileHandle '<utm.txt';
#my $fh = new FileHandle '<lonlat.txt';
ok(defined $fh);

$trail = new GPS::Lowrance::Trail( rounding => 1, read_utm=>$fh );
# $trail->read_utm( $fh );
# $trail->read_lonlat( $fh );

ok(!$trail->errors);


ok($trail->trail_num);

ok($trail->size);

my $fo = new FileHandle '>out.gpx';
ok(defined $fo);

#$trail->write_gdm16( \*STDERR );
# $trail->write_lonlat( \*STDERR );
$trail->write_utm( \*STDERR );

# $trail->write_gpx( $fo );

$fo->close;


