use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
WriteMakefile(
    'NAME'		=> 'GPS::Lowrance::Trail',
    'VERSION_FROM'	=> 'Trail.pm', # finds $VERSION
    'PREREQ_PM'		=> {
      'Carp::Assert'          => 0,
      'FileHandle'            => 0,
      'Geo::Coordinates::UTM' => 0,
      'Geo::Coordinates::DecimalDegrees' => 0,
      'XML::Generator'        => 0,
     },
    ($] >= 5.005 ?    ## Add these new keywords supported since 5.005
      (ABSTRACT_FROM => 'Trail.pm', # retrieve abstract from module
       AUTHOR     => 'Robert Rothenberg <rrwo at cpan.org>') : ()),
);
