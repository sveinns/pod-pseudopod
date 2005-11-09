#!/usr/bin/perl -w

# t/text.t - check output from Pod::PseudoPod::Text

BEGIN {
    chdir 't' if -d 't';
}

use strict;
use lib '../lib';
use Test::More tests => 20;

use_ok('Pod::PseudoPod::Text') or exit;

my $parser = Pod::PseudoPod::Text->new ();
isa_ok ($parser, 'Pod::PseudoPod::Text');

my $results;

initialize($parser, $results);
$parser->parse_string_document( "=head0 Narf!" );
is($results, "Narf!\n\n", "head0 level output");

initialize($parser, $results);
$parser->parse_string_document( "=head1 Poit!" );
is($results, "Poit!\n\n", "head1 level output");

initialize($parser, $results);
$parser->parse_string_document( "=head2 I think so Brain." );
is($results, " I think so Brain.\n\n", "head2 level output");

initialize($parser, $results);
$parser->parse_string_document( "=head3 I say, Brain..." );
is($results, "  I say, Brain...\n\n", "head3 level output");

initialize($parser, $results);
$parser->parse_string_document( "=head4 Zort!" );
is($results, "   Zort!\n\n", "head4 level output");

initialize($parser, $results);
$parser->parse_string_document(<<'EOPOD');
=pod

Gee, Brain, what do you want to do tonight?
EOPOD

is($results, <<'EOTXT', "simple paragraph");
    Gee, Brain, what do you want to do tonight?

EOTXT

initialize($parser, $results);
$parser->parse_string_document(<<'EOPOD');
=pod

B: Now, Pinky, if by any chance you are captured during this mission,
remember you are Gunther Heindriksen from Appenzell. You moved to
Grindelwald to drive the cog train to Murren. Can you repeat that?

P: Mmmm, no, Brain, don't think I can.
EOPOD

is($results, <<'EOTXT', "multiple paragraphs");
    B: Now, Pinky, if by any chance you are captured during this mission,
    remember you are Gunther Heindriksen from Appenzell. You moved to
    Grindelwald to drive the cog train to Murren. Can you repeat that?

    P: Mmmm, no, Brain, don't think I can.

EOTXT

initialize($parser, $results);
$parser->parse_string_document(<<'EOPOD');
=over

=item *

P: Gee, Brain, what do you want to do tonight?

=item *

B: The same thing we do every night, Pinky. Try to take over the world!

=back

EOPOD

is($results, <<'EOTXT', "simple bulleted list");
      * P: Gee, Brain, what do you want to do tonight?

      * B: The same thing we do every night, Pinky. Try to take over the
      world!

EOTXT

initialize($parser, $results);
$parser->parse_string_document(<<'EOPOD');
=over

=item 1

P: Gee, Brain, what do you want to do tonight?

=item 2

B: The same thing we do every night, Pinky. Try to take over the world!

=back

EOPOD

is($results, <<'EOTXT', "numbered list");
      1. P: Gee, Brain, what do you want to do tonight?

      2. B: The same thing we do every night, Pinky. Try to take over the
      world!

EOTXT

initialize($parser, $results);
$parser->parse_string_document(<<'EOPOD');
=over

=item Pinky

Gee, Brain, what do you want to do tonight?

=item Brain

The same thing we do every night, Pinky. Try to take over the world!

=back

EOPOD

is($results, <<'EOTXT', "list with text headings");
    Pinky

      Gee, Brain, what do you want to do tonight?

    Brain

      The same thing we do every night, Pinky. Try to take over the world!

EOTXT

initialize($parser, $results);
$parser->parse_string_document(<<'EOPOD');
=pod

  1 + 1 = 2;
  2 + 2 = 4;

EOPOD

is($results, <<'EOTXT', "code block");
      1 + 1 = 2;
      2 + 2 = 4;

EOTXT

initialize($parser, $results);
$parser->parse_string_document(<<'EOPOD');
=pod

A plain paragraph with a C<functionname>.
EOPOD
is($results, <<"EOTXT", "code entity in a paragraph");
    A plain paragraph with a functionname.

EOTXT

initialize($parser, $results);
$parser->parse_string_document(<<'EOPOD');
=pod

A plain paragraph with aN<footnote entry>.
EOPOD
is($results, <<"EOTXT", "footnote entity in a paragraph");
    A plain paragraph with a [footnote: footnote entry].

EOTXT

initialize($parser, $results);
$parser->parse_string_document(<<'EOPOD');
=pod

A plain paragraph with a U<http://test.url.com/stuff/and/junk.txt>.
EOPOD
is($results, <<"EOHTML", "URL entity in a paragraph");
    A plain paragraph with a http://test.url.com/stuff/and/junk.txt.

EOHTML

initialize($parser, $results);
$parser->parse_string_document(<<'EOPOD');
=pod

A plain paragraph with a Z<crossreferenceendpoint>cross-reference.
EOPOD
is($results, <<"EOHTML", "Link anchor entity in a paragraph");
    A plain paragraph with a cross-reference.

EOHTML
initialize($parser, $results);
$parser->parse_string_document(<<'EOPOD');
=for text
This is a dummy for block.

EOPOD
is($results, <<"EOTXT", "a simple 'for' block");
    This is a dummy for block.

EOTXT

initialize($parser, $results);
$parser->parse_string_document(<<'EOPOD');
=begin text

This is a dummy begin block.

=end text
EOPOD
is($results, <<"EOTXT", "a simple 'begin' block");
    This is a dummy begin block.

EOTXT
initialize($parser, $results);
$parser->parse_string_document(<<'EOPOD');
=pod

A plain paragraph with a link anchorZ<crossreferenceendpoint>.
EOPOD
is($results, <<"EOTXT", "Link anchor entity in a paragraph");
    A plain paragraph with a link anchor.

EOTXT

######################################

sub initialize {
	$_[0] = Pod::PseudoPod::Text->new ();
	$_[0]->output_string( \$results ); # Send the resulting output to a string
	$_[1] = '';
	return;
}
