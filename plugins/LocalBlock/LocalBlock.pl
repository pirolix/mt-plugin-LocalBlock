package MT::Plugin::OMV::LocalBlock;
########################################################################
#   Local Block - Make block that has localized scope of variables
#           Copyright (c) 2007-2008 Hiroyuki UENISHI
#           Open MagicVox.net - http://www.magicvox.net/
########################################################################
use strict;
use MT 4.0;
use MT::Template::Context;

use vars qw( $VENDOR_NAME $MYNAME $VERSION );
$VENDOR_NAME = 'OMV';
$MYNAME = 'LocalBlock';
$VERSION = '1.00';

### Register as a plugin
use base qw( MT::Plugin );
my $plugin = MT::Plugin::OMV::LocalBlock->new({
        name => $MYNAME,
        version => $VERSION,
        author_name => 'Hiroyuki UENISHI',
        author_link => 'http://www.magicvox.net/',
        plugin_link => 'http://www.magicvox.net/archive/2008/02241215/',
        description => <<HTMLHEREDOC,
Make block that has localized scope of variables
HTMLHEREDOC
        registry => {
            tags => {
                block => {
                    'LocalBlock' => \&_mt_local_block,
                },
            },
        },
});
MT->add_plugin( $plugin );

sub instance { $plugin }



sub _mt_local_block {
    my( $ctx, $args, $cond ) = @_;

    # Prepare localized variables
    my $vars = $ctx->{__stash}{vars};
    local $ctx->{__stash}{vars};
    map { $ctx->var( $_, $vars->{$_}) } keys %{$vars};

    # Build it!
    my $builder = $ctx->stash( 'builder' );
    my $tokens  = $ctx->stash( 'tokens' );
    my $out = $builder->build( $ctx, $tokens, $cond )
        or return $ctx->error( $builder->errstr );

    # Get back into global variables
    if( defined( my $globals = $args->{globals})) {
        map { $vars->{$_} = $ctx->var( $_ ) if /$globals/ } keys %{$vars};
    }

    $out;
}

1;