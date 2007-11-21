package Data::Domain::SemanticAdapter::Test;

use strict;
use warnings;
use Hash::Rename;
use Test::More;


our $VERSION = '0.01';


use base qw(Data::Semantic::Test);


sub munge_args {
    my ($self, %args) = @_;

    # Our keys have a dash at the beginning - make sure every key has one.
    # This also makes it possible to use Data::Semantic::*::TestData::*
    # classes' data as it is automatically munged into the format we want.

    hash_rename %args, code => sub { s/^(?!-)/-/ };
    %args;
}


sub test_is_valid {
    my ($self, $obj, $value, $testname) = @_;
    # can be empty string or 0
    like($obj->inspect($value), qr/^0?$/, $testname);
}


sub test_is_invalid {
    my ($self, $obj, $value, $testname) = @_;
    # can be empty string or 0
    like($obj->inspect($value), qr/^(\w+)(::\w+)*: invalid$/, $testname);
}


# convenience test methods

sub is_excluded {
    my ($self, $domain, $data) = @_;
    like(
        $domain->inspect($data),
        qr/^(\w+)(::\w+)*: belongs to exclusion set$/,
        "excluded: $data"
    );
}


sub is_invalid {
    my ($self, $domain, $data) = @_;
    $self->test_is_invalid($domain, $data, "invalid: $data");
}


sub is_valid {
    my ($self, $domain, $data) = @_;
    $self->test_is_valid($domain, $data, "valid: $data");
}


1;


__END__



=head1 NAME

Data::Domain::SemanticAdapter::Test - testing Data::Domain objects

=head1 SYNOPSIS

    Data::Domain::SemanticAdapter::Test->new;

=head1 DESCRIPTION

This class can be used to test classes deriveed from
L<Data::Domain::SemanticAdapter>. It works in conjunction with
L<Test::CompanionClasses>.

Data::Domain::SemanticAdapter::Test inherits from L<Data::Semantic::Test>.

The superclass L<Data::Semantic::Test> defines these methods and functions:

    PLAN(), run()

The superclass L<Test::CompanionClasses::Base> defines these methods and
functions:

    new(), clear_package(), make_real_object(), package(), package_clear(),
    planned_test_count()

The superclass L<Class::Accessor::Complex> defines these methods and
functions:

    carp(), cluck(), croak(), flatten(), mk_abstract_accessors(),
    mk_array_accessors(), mk_boolean_accessors(),
    mk_class_array_accessors(), mk_class_hash_accessors(),
    mk_class_scalar_accessors(), mk_concat_accessors(),
    mk_forward_accessors(), mk_hash_accessors(), mk_integer_accessors(),
    mk_new(), mk_object_accessors(), mk_scalar_accessors(),
    mk_set_accessors(), mk_singleton()

The superclass L<Class::Accessor> defines these methods and functions:

    _carp(), _croak(), _mk_accessors(), accessor_name_for(),
    best_practice_accessor_name_for(), best_practice_mutator_name_for(),
    follow_best_practice(), get(), make_accessor(), make_ro_accessor(),
    make_wo_accessor(), mk_accessors(), mk_ro_accessors(),
    mk_wo_accessors(), mutator_name_for(), set()

The superclass L<Class::Accessor::Installer> defines these methods and
functions:

    install_accessor(), subname()

The superclass L<Data::Inherited> defines these methods and functions:

    every_hash(), every_list(), flush_every_cache_by_key()

=head1 METHODS

=over 4



=item munge_args

Test data classes usually define C<TESTDATA()> to have arguments without
leading dashes. This method munges the args to the usual L<Data::Domain> style
by prepending a dash to those keys that don't already start with a dash.

So if the C<TESTDATA()> looks like this:


    use constant TESTDATA => (
        {
            args => { foo => 1, bar => 'baz' },
            valid => [ qw(
                ...
            ) ],
            invalid => [ qw(
                ...
            ) ],
        },
    );

the data domain object to be passed will effectlvely be constructed like this:

    $self->make_real_object('-foo' => 1', '-bar' => 'baz');

C<make_real_object()> comes from L<Test::CompanionClasses::Base>.

=item test_is_valid

Overrides this method by passing the value to be tested to the data domain
object's C<inspect()> method and checking that it either returns an empty
string or C<0>.

=item test_is_invalid

Overrides this method by passing the value to be tested to the data domain
object's C<inspect()> method and checking that it returns an C<INVALID>
message as defined in L<Data::Domain>.

=item is_excluded

Takes a data domain object and a value to be tested. Passes the value to the
data domain object's C<inspect()> method and checks whether it returns an
C<EXCLUSION_SET> message as defined in L<Data::Domain>.

=item is_invalid

Takes a data domain object and a value to be tested. Passes the value to the
data domain object's C<inspect()> method and checks whether it returns an
C<INVALID> message as defined in L<Data::Domain>.

This method differs from C<test_is_invalid()> in that the latter is called
while iterating over C<TESTDATA()> and so it gets a test name as an argument,
while this method can be used for custom tests - it creates its own test
name.

=item is_valid

Analoguous to C<is_invalid()>.

=back

=head1 TAGS

If you talk about this module in blogs, on del.icio.us or anywhere else,
please use the C<datadomainsemanticadapter> tag.

=head1 VERSION 
                   
This document describes version 0.01 of L<Data::Domain::SemanticAdapter::Test>.

=head1 BUGS AND LIMITATIONS

No bugs have been reported.

Please report any bugs or feature requests to
C<<bug-data-domain-semanticadapter@rt.cpan.org>>, or through the web interface at
L<http://rt.cpan.org>.

=head1 INSTALLATION

See perlmodinstall for information and options on installing Perl modules.

=head1 AVAILABILITY

The latest version of this module is available from the Comprehensive Perl
Archive Network (CPAN). Visit <http://www.perl.com/CPAN/> to find a CPAN
site near you. Or see <http://www.perl.com/CPAN/authors/id/M/MA/MARCEL/>.

=head1 AUTHOR

Marcel GrE<uuml>nauer, C<< <marcel@cpan.org> >>

=head1 COPYRIGHT AND LICENSE

Copyright 2007 by Marcel GrE<uuml>nauer

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.


=cut
