package Form;

use strict;
use base 'N3::Hashable';
use N3::Util;

sub new {
    my $class = shift;
    my $self = shift;
    $self->{verifier} = N3::Util->encrypt($self->{name} . '-' . scalar time);
    return bless $self, $class;
}

sub name {
    my $self = shift;
    $self->{name} = shift if @_;
    return $self->{name};
}

sub check {
    my $self = shift;
    my $request = $self->request;
    return 0 unless $request->param('check_' . $self->name);
    my $checked = 1;
    if (!$self->verifier_ok) {
        $checked = 0;
	$self->error_text("Invalid submission") if $request->param('verifier_' . $self->name);
    }
    foreach my $field ($self->fields) {
	$self->field_check($field);
    }
    $checked = 0 if $self->error;
    return $checked;
}

sub error {
    my $self = shift;
    $self->{error} = shift if @_;
    return $self->{error};
}

sub error_text {
    my $self = shift;
    $self->{error_text} = shift if @_;
    return $self->{error_text};
}

sub verifier {
    my $self = shift;
    return $self->{verifier};
}

sub verifier_ok {
    my $self = shift;
    my $request = $self->request;
    my $submitted_verifier = $request->param('verifier_' . $self->name);
    return 0 unless $submitted_verifier;
    my $plaintext = N3::Util->decrypt($submitted_verifier); 
    my $now = scalar time;
    my ($name, $form_time) = split(/-/, $plaintext);
    return 0 unless $name = $self->name;
    return 0 unless $now - $form_time <= 86400; # form is no older than a day
    return 1;
}

sub val {
    my $self = shift;
    my $name = shift;
    $self->{_vals}{$name} = shift if @_;
    return $self->{_vals}{$name};
}

sub field_check {
    my $self = shift;
    my $field = shift;
    my $request = $self->request;
    die "Must have a request object" unless $request;
    my @needs_validate;
    if ($field->{fields}) {
	foreach my $subfield (@{$field->{fields}}) {
	    $self->field_check($subfield);
	}
    }
    else {
	$field->{value} = $request->param($field->{name});
	$self->val($field->{name}, $field->{value});
	if (!$field->{value} && $field->{required}) {
	    $self->error(1);
	    $field->{error} = "Required";
	}
	push @needs_validate, $field if $field->{validate} && !$field->{error};
    }
    foreach my $field (@needs_validate) {
	my $function = $field->{validate};
	my $error = &$function($field, $self);
	if ($error) {
	    $self->error(1);
	    $field->{error} = $error;
	}
    }
}

sub request {
    # should be N3->request or Apache2::Request
    my $self = shift;
    $self->{_request} = shift if @_;
    return $self->{_request};
}

sub fields {
    my $self = shift;
    $self->{fields} = shift if @_;
    return wantarray ? @{$self->{fields}} : $self->{fields};
}

1;
