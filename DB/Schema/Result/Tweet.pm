package DB::Schema::Result::Tweet;
use base qw/DBIx::Class::Core/;

__PACKAGE__->table('tweet');
__PACKAGE__->add_columns(qw/ user_id text /);

1;
