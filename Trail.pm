package GPS::Lowrance::Trail;

use 5.006;
use strict;

use Carp::Assert;
use Geo::Coordinates::UTM;

our $VERSION = '0.21';

require FileHandle;

sub new
  {
    my $class = shift;

    my $self  = {
      TRAIL   => 1,
      COUNT   => 0,
      POINTS  => [ ],
      ERRORS  => 0,
    };

    bless $self, $class;
  }

sub trail_num
  {
    my $self = shift;
    assert( UNIVERSAL::isa( $self, __PACKAGE__ ) ), if DEBUG;

    if (@_) {
      # To-Do: We should check that trail number is between 1 and 4
      $self->{TRAIL} = shift;
    } else {
      return $self->{TRAIL};
    }
  }

sub errors
  {
    my $self = shift;
    assert( UNIVERSAL::isa( $self, __PACKAGE__ ) ), if DEBUG;

    if (@_) {
      # To-Do: We should check that trail number is between 1 and 4
      $self->{ERRORS} = shift;
    } else {
      return $self->{ERRORS};
    }

  }

sub size
  {
    my $self = shift;
    assert( UNIVERSAL::isa( $self, __PACKAGE__ ) ), if DEBUG;
    return $self->{COUNT};
  }

sub _minsec2dec

  # Converts degrees, minutes, seconds and direction (ie, 40°52'27.9" N)
  # into a decimal (40.874167).

  {
    my ($degrees, $minutes, $seconds, $direction) = @_;

    return ( $degrees + ($minutes / 60) + ($seconds / 3600) ) * 
      ( ($direction =~ m/^[SW]$/i) ? -1 : 1 );

  }


sub _dec2minsec

  {
    my ($decimal, $is_lon) = @_;

    my ($degrees, $minutes, $seconds, $direction);

    if ($is_lon) {
      $direction = ($decimal < 0) ? "W" : "E";
    } else {
      $direction = ($decimal < 0) ? "S" : "N";
    }

    $decimal = abs( $decimal );
    $degrees = int( $decimal );
    $seconds = abs($decimal - $degrees) * 3600;
    $minutes = int( $seconds / 60 );
    $seconds -= ($minutes * 60);

    return ($degrees, $minutes, $seconds, $direction);
  }

sub add_point
  {
    my $self = shift;
    assert( UNIVERSAL::isa( $self, __PACKAGE__ ) ), if DEBUG;

    my ($latitude, $longitude) = @_;

    push @{ $self->{POINTS} }, [ $latitude, $longitude ];
    ++$self->{COUNT};
  }

sub _parse_gdm16_line
  {
    my $line = shift;

    if ($line =~ m/^(\d+)\.\s+Lat: ([NS]) (\d+)\xb0(\d+\.?\d*)\'((\d+\.?\d*)\")?\s+Lon: ([EW]) (\d+)\xb0(\d+\.?\d*)\'((\d+\.?\d*)\")?/)
      {
	my $count = $1;

	my ($latitude, $longitude) = (
	  _minsec2dec( $3, $4, $6, $2 ),
	  _minsec2dec( $8, $9, $11, $7)
        );

	return ($count, $latitude, $longitude);
      }
    else
      {
	return;
      }
  }

sub read_gdm16
  {
    my $self = shift;
    assert( UNIVERSAL::isa( $self, __PACKAGE__ ) ), if DEBUG;

    my $fh   = shift || \*STDIN;
    # assert( UNIVERSAL::isa($fh, "FileHandle") ), if DEBUG;

    my $line = <$fh>;

    if ($line =~ m/^Plot Trail \x23(\d+)/)
      {
	$self->trail_num($1);
      }
    else
      {
	warn "Plot Trail format mismatch";
	$self->errors( $. );
      }

    while ($line = <$fh>)
      {

	my ($count, $latitude, $longitude) =
	  _parse_gdm16_line( $line );

	if ( (defined $latitude) and (defined $longitude) )
	  {
	    $self->add_point( $latitude, $longitude );
	  }
	else
	  {
	    warn "Missing latitude or longitude in line";
	    $self->errors( $. );
	  }
      }

    return $self->{COUNT};
  }

sub read_latlon
  {
    my $self = shift;
    assert( UNIVERSAL::isa( $self, __PACKAGE__ ) ), if DEBUG;

    my $fh   = shift || \*STDIN;
    # assert( UNIVERSAL::isa($fh, "FileHandle") ), if DEBUG;

    my $line = <$fh>;

    if ($line =~ m/^BEGIN LINE/)
      {
      }
    else
      {
	warn "Missing BEGIN LINE header";
	$self->errors( $. );
      }

    while ( ($line = <$fh>) and ($line !~ m/^END/) )
      {
	chomp( $line );

	my ($latitude, $longitude) = split /,/, $line;

	if ( (defined $latitude) and (defined $longitude) )
	  {
	    $self->add_point( $latitude, $longitude );
	  }
	else
	  {
	    warn "Missing latitude or longitude in line";
	    $self->errors( $. );
	  }
      }

    return $self->{COUNT};
  }

sub _dec2gdm16
  {

    my ($decimal, $is_lon) = @_;

    my ($degrees, $minutes, $seconds, $direction) =
      _dec2minsec( $decimal, $is_lon );

    return sprintf("%s %02d\xb0%02d\'%2.1f\"",
		   $direction, $degrees, $minutes, $seconds );
  }

sub write_gdm16
  {
    my $self = shift;
    assert( UNIVERSAL::isa( $self, __PACKAGE__ ) ), if DEBUG;

    my $fh   = shift || \*STDOUT;
    # assert( UNIVERSAL::isa($fh, "FileHandle") ), if DEBUG;

    print $fh "Plot Trail \x23", $self->trail_num(), "\n";

    my $counter = 1;

    foreach my $point (@{$self->{POINTS}})
      {
	print $fh
	  $counter++,
	  ". \t",
          "Lat: ",
	    _dec2gdm16($point->[0], 0),
          "  \t",
	  "Lon: ",
	    _dec2gdm16($point->[1], 1),
	  "\n";
      }
  }

sub write_utm
  {
    my $self = shift;
    assert( UNIVERSAL::isa( $self, __PACKAGE__ ) ), if DEBUG;

    my $fh   = shift || \*STDOUT;
    # assert( UNIVERSAL::isa($fh, "FileHandle") ), if DEBUG;

    print $fh "BEGIN LINE\n";

    foreach my $point (@{$self->{POINTS}})
      {
	my ($zone, $east, $north) = latlon_to_utm( 23, @$point );
	print $fh join(",", $zone, map { sprintf('%010.2f', $_) } $east, $north ), "\n";
      }

    print $fh "END\n";
  }

sub write_latlon
  {
    my $self = shift;
    assert( UNIVERSAL::isa( $self, __PACKAGE__ ) ), if DEBUG;

    my $fh   = shift || \*STDOUT;
    # assert( UNIVERSAL::isa($fh, "FileHandle") ), if DEBUG;

    print $fh "BEGIN LINE\n";

    foreach my $point (@{$self->{POINTS}})
      {
	print $fh join(",", map { sprintf('%1.6f', $_) } @$point), "\n";
      }

    print $fh "END\n";
  }

sub get_trail
  {
    my $self = shift;
    assert( UNIVERSAL::isa( $self, __PACKAGE__ ) ), if DEBUG;

    return $self->{POINTS};
  }

BEGIN {
  no warnings;
  *read_lonlat  = \&read_latlon;
  *write_lonlat = \&write_latlon;
}

1;
__END__


=head1 NAME

GPS::Lowrance::Trail - Convert between GDM16 Trails and other formats

=head1 REQUIREMENTS

The following non-standard modules are used:

  Carp::Assert
  Geo::Coordinates::UTM

=head2 Installation

Installation is pretty standard:

  perl Makefile.PL
  make
  make test
  make install

There is no test suite to speak of. One will be added in a later version.

=head1 SYNOPSIS

  use GPS::Lowrance::Trail;

  my $trail = new GPS::Lowrance::Trail;

  my $fh1 = new FileHandle '<lowrance.txt';
  my $fh2 = new FileHandle '>lonlat.txt';

  $trail->read_gdm16( $fh1 );      # read GDM16 Trail Exports

  $trail->write_latlon( $fh2 );    # write as Longitude/Latitude file

=head1 DESCRIPTION

This module allows one to convert between Lowrance GPS trail files
(handled by the GDM16 application) and Latitude/Longitude files
which may be used by mapping applications.

=head2 Methods

The following methods are implemented.

=over

=item new

  my $trail = new GPS::Lowrance::Trail;

Generates a new instance of the object.

=item trail_num

  $trail->trail_num(1);

  if ($trail->trail_num() > 4) { ... }

Sets or gets the "Plot Trail" number indicated in the GDM16 trail export.
GDM16 does not seem to care about this number when importing a trail.

The number should be between 1 and 4 (corresponding to what GDM16 allows)
although the C<GPS::Lowrance::Trail> module does not care.

=item add_point

  $trail->add_point( $longitude, $latitude );

Add a point to the trail. C<$longitude> and C<$latitude> are in decimal
form.

=item size

  $trail->size();

Returns the number of points on the trail.

=item get_trail

  my $array_ref = $trail->get_trail;

Returns a reference to an array of all trail points (where each point
is an array reference to the latitude and longitude).

=item read_gdm16

  my $fh = FileHandle "mytrail.txt";

  $trail->read_gdm16( $fh );

Read a trail file in GDM16 format. Points are appended to the last point.

=item read_latlon

Read a trail file in Latitude/Longitude file format. Points are appended
to the last point.

=item write_gdm16

Write a trail file in GDM16 format.

=item write_latlon

Write a trail file in Longitude/Latitude format.

=item write_utm

Write a tail file in UTM (Universal Tranverse Mercator) format.
Assumes WGS-84 datum.

=item errors

Returns a value if there were errors when reading a file.

=back

=head2 Export

None by default.

=head2 Exporting Trail Files from GDM16

Trail data can be extracted from the GDM16 utility (which is
distributed by Lowrance at L<http://www.lowrance.com>) or Eagle at
L<http://www.eaglegps.com>.

To do so, choose the "Trails" tab, select "Edit" and then "Copy", then
open your favorite text editor and paste from the clipboard.

What you have is the file format which this Perl module processes.

Likewise, to import a trail file, open one of these files, "Select All"
and "Copy" the file, load GDM16, select the "Trails" tab and choose 
"Edit" and "Paste".

=head1 CAVEATS

This module comes from a quick and dirty hack adapted from a one-off
script written for this purpose.  It appears to work, but has not been
fully tested.

More features and file formats may be added in the future.

=head1 SEE ALSO

C<GPS::Lowrance> implements higher-level functions to extract trails
and other information directly from the GPS device.

=head1 AUTHOR

Robert Rothenberg <rrwo at cpan.org>

=head2 Suggestions and Bug Reporting

Feedback is always welcome.  Please report any bugs using the CPAN
Request Tracker at L<http://rt.cpan.org>.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2002,2004 by Robert Rothenberg <rrwo at cpan.org>.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
