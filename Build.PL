use Module::Build;

my $build = Module::Build->new
    (
     module_name => 'GPS::Lowrance::Trail',
     license => 'perl',
     requires => {
       'perl'                       => '5.6.1',
       'Carp::Assert'               => 0,
       'FileHandle'                 => 0,
       'Geo::Coordinates::DecimalDegrees' => 0,
       'Geo::Coordinates::UTM'      => 0,
       'XML::Generator'             => 0,
     },
     recommends => {
     },
     autosplit => [qw( lib/GPS/Lowrance/Trail.pm )],
     create_makefile_pl => 'traditional',
     dist_author        => 'Robert Rothenberg <rrwo at cpan.org>',
);

$build->create_build_script;
