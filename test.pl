
use Test;
BEGIN { plan tests => 2 };
use GPS::Lowrance::Trail;
ok(1); # If we made it this far, we're ok.

my $trail = new GPS::Lowrance::Trail;
ok(defined $trail);

exit 0;

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

my $fo = new FileHandle 'out.txt', O_WRONLY;
ok(defined $fo);

# $trail->write_lonlat( $fo );
$trail->write_gdm16( $fo );



