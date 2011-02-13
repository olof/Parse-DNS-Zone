#!/usr/bin/perl
use strict;
use warnings;
use ExtUtils::MakeMaker;

WriteMakefile (
	NAME => 'Parse::DNS::Zone',
	AUTHOR => 'Olof Johansson <olof@cpan.org>',
	LICENSE => 'perl',
	ABSTRACT_FROM => 'lib/Parse/DNS/Zone.pm',
	VERSION_FROM => 'lib/Parse/DNS/Zone.pm',
	SIGN => 1,

	PREREQ_PM => {
		'Test::More' => 0,
	},

	MAN3PODS => {
		'lib/Parse/DNS/Zone.pm' => 'blib/man3/Parse::DNS::Zone.3pm'
	},

	PM => {
		'lib/Parse/DNS/Zone.pm' => '$(INST_LIBDIR)/Zone.pm'
	}
);

