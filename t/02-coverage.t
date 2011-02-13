use Test::More;

eval "use Test::Pod::Coverage tests=>1";
plan skip_all => 'Test::Pod::Coverage required' if $@;
pod_coverage_ok("Parse::DNS::Zone",  { also_private => [ qr/^_.+$/ ] }, 
                "Foo::Bar, with functions beinning with _ as privates",);

