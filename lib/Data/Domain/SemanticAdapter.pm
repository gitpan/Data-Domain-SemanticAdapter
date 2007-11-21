package Data::Domain::SemanticAdapter;

use strict;
use warnings;
use Carp;
use UNIVERSAL::require;


our $VERSION = '0.01';


use base qw(
    Data::Domain
    Data::Inherited
    Class::Accessor::Complex
);


__PACKAGE__->mk_scalar_accessors(qw(adaptee));


# sub adaptee() to be defined in subclasses

use constant OPTIONS => ();


sub new {
    my $class = shift;
    my $self = bless {}, $class;

    my @options = (qw/-not_in/, $self->every_list('OPTIONS'));
    my $parsed = Data::Domain::_parse_args(\@_, \@options);

    while (my ($key, $value) = each %{ $parsed || {} }) {
        $self->{$key} = $value;
    }
  
    if ($self->{-not_in}) {
        @{ $self->{-not_in} || [] } > 0 or
            croak "-not_in : needs an arrayref of values";
    }

    my $semantic_class_name = $self->semantic_class_name;
    $semantic_class_name->require;
    $self->adaptee($semantic_class_name->new($self->semantic_args));

    $self;
}


# Default; subclasses can redefine this. But it makes sense to keep the
# Data::Domain::* and Data::Semantic::* namespaces in sync.

sub semantic_class_name {
    my $self = shift;
    (my $semantic_class_name = ref $self) =~
        s/^Data::Domain::/Data::Semantic::/;
    $semantic_class_name;
}


# Turn the options accepted because of OPTIONS() into args to be passed to the
# adaptee constructor. Here we provide a sensibe default.

sub semantic_args {
    my $self = shift;
    my %args;
    for my $option ($self->OPTIONS) {
        (my $semantic_key = $option) =~ s/^-//;
        $args{$semantic_key} = $self->{$option} if defined $self->{$option};
    }
    %args;
}


sub _inspect {
    my ($self, $data) = @_;
  
    $self->adaptee->is_valid($data)
        or return $self->msg(INVALID => $data);

    if (defined $self->{-not_in}) {
        grep { $data eq $_} @{ $self->{-not_in} }
            and return $self->msg(EXCLUSION_SET => $data);
    }
}


# mirror the Data::Semantic::Name namespace classes

sub install_shortcuts {
    my %map = @_;
    my $call_pkg = (caller)[0];
    while (my ($domain, $class) = each %map) {
        no strict 'refs';
        my $domain_class_name = "Data::Domain::$class";
        $domain_class_name->require;
        *{ "${call_pkg}::${domain}" } = sub { $domain_class_name->new(@_) };
    }
}


1;


__END__



=head1 NAME

Data::Domain::SemanticAdapter - Adapter for Data::Semantic objects

=head1 SYNOPSIS

    Data::Domain::SemanticAdapter->new;

=head1 DESCRIPTION

This class is an adapter (wrapper) that turns L<Data::Semantic> objects into
L<Data::Domain> objects.

It, and therefore all the subclasses, support a C<-not_in> options. If given,
the data must be different from all values in the exclusion set, supplied
as an arrayref.

Data::Domain::SemanticAdapter inherits from L<Data::Domain>,
L<Data::Inherited>, and L<Class::Accessor::Complex>.

The superclass L<Data::Domain> defines these methods and functions:

    Date(), Enum(), Int(), List(), Num(), One_of(), String(), Struct(),
    Time(), Whatever(), _check_range(), _parse_args(), import(), inspect(),
    messages(), msg(), node_from_path(), subclass()

The superclass L<Data::Inherited> defines these methods and functions:

    every_hash(), every_list(), flush_every_cache_by_key()

The superclass L<Class::Accessor::Complex> defines these methods and
functions:

    cluck(), flatten(), mk_abstract_accessors(), mk_array_accessors(),
    mk_boolean_accessors(), mk_class_array_accessors(),
    mk_class_hash_accessors(), mk_class_scalar_accessors(),
    mk_concat_accessors(), mk_forward_accessors(), mk_hash_accessors(),
    mk_integer_accessors(), mk_new(), mk_object_accessors(),
    mk_scalar_accessors(), mk_set_accessors(), mk_singleton()

The superclass L<Class::Accessor> defines these methods and functions:

    _carp(), _croak(), _mk_accessors(), accessor_name_for(),
    best_practice_accessor_name_for(), best_practice_mutator_name_for(),
    follow_best_practice(), get(), make_accessor(), make_ro_accessor(),
    make_wo_accessor(), mk_accessors(), mk_ro_accessors(),
    mk_wo_accessors(), mutator_name_for(), set()

The superclass L<Class::Accessor::Installer> defines these methods and
functions:

    install_accessor(), subname()

=head1 METHODS

=over 4

=item adaptee

    my $value = $obj->adaptee;
    $obj->adaptee($value);

A basic getter/setter method. If called without an argument, it returns the
value. If called with a single argument, it sets the value.

=item adaptee_clear

    $obj->adaptee_clear;

Clears the value.

=item clear_adaptee

    $obj->clear_adaptee;

Clears the value.

=item semantic_class_name

Returns the corresponding semantic class name. This method provides a default
mapping, the idea of which is to mirror the layout of the Data::Semantic class
tree. If you have a different mapping, override this method in a subclass.

So in the Data::Domain::URI::http class, it will return
C<Data::Semantic::URI::http>.

=item adaptee

Takes the results of C<semantic_class_name()> and C<semantic_args()>, loads
the semantic data class and returns a semantic data object with the given args
passed to its constructor.

=item semantic_args

Turns the object's options, specified via C<OPTIONS()>, into arguments to be
passed to the semantic data object's constructor. Returns a hash.

=item _inspect

Inspects the data using the C<adaptee()>. See L<Data::Domain> for more
information. Respects the C<-not_in> option and returns a C<EXCLUSION_SET>
message, if appropriate. If the adaptee() says that the data is not valid
under the given options, an C<INVALID> message is returned.

=item install_shortcuts

This is a convenience function (not method) that installs shortcuts into the
calling package. It expects a mapping hash whose keys are the shortcuts to be
created and whose values are the package names relative to C<Data::Domain::>.
See L<Data::Domain>, section I<Shortcut functions for domain constructors>, for
more information on shortcuts.

Here is an example from L<Data::Domain::Net>:

    our %map = (
        IPv4 => 'Net::IPAddress::IPv4',
        IPv6 => 'Net::IPAddress::IPv6',
    );

    Data::Domain::SemanticAdapter::install_shortcuts(%map);

This installs two functions, C<IPv4()> and C<IPv6()>, into Data::Domain::Net.
Now code that wants to use network-based domain objects can just say:

    use Data::Domain::Net ':all';

    my $domain = IPv4(-not_in => [ ... ]);
    $domain->inspect(...);

=back

=head1 TAGS

If you talk about this module in blogs, on del.icio.us or anywhere else,
please use the C<datadomainsemanticadapter> tag.

=head1 VERSION 
                   
This document describes version 0.01 of L<Data::Domain::SemanticAdapter>.

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

