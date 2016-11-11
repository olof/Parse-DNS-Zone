use Test::More;

BEGIN {
	plan skip_all => "set RELEASE_TESTING to test"
		unless $ENV{RELEASE_TESTING};
	eval { require Test::CPAN::Changes };
	plan skip_all => "$@" if $@;
	Test::CPAN::Changes::changes_ok();
}
