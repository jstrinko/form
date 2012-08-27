package Form;

use base 'N3::Hashable';

sub new {
    my $class = shift;
    my $self = shift;
    return bless $self, $class;
}

sub check {
    return 0;
}

1;
