use Moose::Util::TypeConstraints;

enum 'Action', [qw/FetchUrl Store NONE/];

no Moose::Util::TypeConstraints;
