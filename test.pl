
use Test;
BEGIN { plan tests => 6 };
use GPS::Lowrance::Trail 0.20;
ok(1);

my $trail = new GPS::Lowrance::Trail;
ok(defined $trail);

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

# my $fh = new FileHandle '<lowrance.txt';
my $fh = new FileHandle '<lonlat.txt';
ok(defined $fh);

# $trail->read_gdm16( $fh );
$trail->read_lonlat( $fh );

ok(!$trail->errors);


ok($trail->trail_num);

ok($trail->size);

my $fo = new FileHandle '>out.txt';
ok(defined $fo);

# $trail->write_lonlat( $fo );
$trail->write_gdm16( $fo );

