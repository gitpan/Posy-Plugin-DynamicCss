package Posy::Plugin::DynamicCss;
use strict;

=head1 NAME

Posy::Plugin::DynamicCss - Posy plugin to load different CSS styles based on the UserAgent.

=head1 VERSION

This describes version B<0.41> of Posy::Plugin::DynamicCss.

=cut

our $VERSION = '0.41';

=head1 SYNOPSIS

    @plugins = qw(Posy::Core
	Posy::Plugin::YamlConfig
	...
	Posy::Plugin::DynamicCss
	...
	));
    @actions = qw(init_params
	    ...
	    head_template
	    dynamic_css_set
	    head_render
	    ...
	);

=head1 DESCRIPTION

This plugin enables Posy users to load different CSS stylesheets
based on the UserAgent.

There is one variable filled in by this plugin that can be used within your
flavour files.  The $flow_dynamic_css_line variable contains the stylesheet
link metatag for the currently selected (browser-specific) CSS file.  This
variable must be inserted into your head flavour file.

=head2 Activation

This plugin needs to be added to both the plugins list and the actions
list.  It doesn't really matter where it is in the plugins list,
just so long as you also have the Posy::Plugin::YamlConfig plugin
as well.

In the actions list, 'dynamic_css_set' needs to go somewhere after
B<head_template> and before B<head_render>, since the config needs to have been
read, and this needs to set values before the head is rendered.

=head2 Configuration

This expects configuration settings in the $self->{config} hash,
which, in the default Posy setup, can be defined in the main "config"
file in the config directory.

This requires the Posy::Plugin::YamlConfig plugin (or equivalent), because the
configuration variables for this plugin are not simple string values; it
expects the config values to be in a hash at $self->{config}->{dynamic_css}

=over 

=item B<dynamic_css>

A hash containing the settings.

=over

=item B<default>

The default CSS link to use when one can't figure out the browser.

=item B<files>

A hash containing, for each browser, the browser string to compare against,
and the CSS link to use if it matches.

=back

=back

Example config file:

	---
	dynamic_css:
	  default: '/styles/layout_netscape.css'
	  files:
	    gecko: '/styles/layout_gecko.css'
	    'MSIE.6|MSIE.5': '/styles/layout_msie.css'
	    'Mozilla.4' : '/styles/layout_netscape.css'

=cut

=head1 Flow Action Methods

Methods implementing actions.

=head2 dynamic_css_set

$self->dynamic_css_set($flow_state)

Sets $flow_state->{dynamic_css_line} 
(aka $flow_dynamic_css_line)
to be used inside flavour files.

=cut
sub dynamic_css_set {
    my $self = shift;
    my $flow_state = shift;

    my $user = $ENV{HTTP_USER_AGENT};
    my $included = 0;
    my $fullpath = $self->{url};
    $fullpath =~ s/\/index.cgi//;
    $fullpath .= $self->{config}->{dynamic_css}->{csspath};
    my $cssline = '';
    my $done = 0;
    my $default_link = $self->{config}->{dynamic_css}->{default};
 
    while (my ($regex, $link) = each
    %{$self->{config}->{dynamic_css}->{files}}) {
	if ($user =~ /$regex/i) {
	    $cssline = "<link rel=\"stylesheet\" type=\"text/css\" 
                              href=\"$link\" //>";
	    $done = 1;
	    last;
	}
    }
    if (! $done) {
	$cssline = "<link rel=\"stylesheet\" type=\"text/css\" 
                              href=\"$default_link\" //>";
    }	
    $flow_state->{dynamic_css_line} = $cssline;
    1;
} # dynamic_css_set

=head1 INSTALLATION

Installation needs will vary depending on the particular setup a person
has.

=head2 Administrator, Automatic

If you are the administrator of the system, then the dead simple method of
installing the modules is to use the CPAN or CPANPLUS system.

    cpanp -i Posy::Plugin::DynamicCss

This will install this plugin in the usual places where modules get
installed when one is using CPAN(PLUS).

=head2 Administrator, By Hand

If you are the administrator of the system, but don't wish to use the
CPAN(PLUS) method, then this is for you.  Take the *.tar.gz file
and untar it in a suitable directory.

To install this module, run the following commands:

    perl Build.PL
    ./Build
    ./Build test
    ./Build install

Or, if you're on a platform (like DOS or Windows) that doesn't like the
"./" notation, you can do this:

   perl Build.PL
   perl Build
   perl Build test
   perl Build install

=head2 User With Shell Access

If you are a user on a system, and don't have root/administrator access,
you need to install Posy somewhere other than the default place (since you
don't have access to it).  However, if you have shell access to the system,
then you can install it in your home directory.

Say your home directory is "/home/fred", and you want to install the
modules into a subdirectory called "perl".

Download the *.tar.gz file and untar it in a suitable directory.

    perl Build.PL --install_base /home/fred/perl
    ./Build
    ./Build test
    ./Build install

This will install the files underneath /home/fred/perl.

You will then need to make sure that you alter the PERL5LIB variable to
find the modules, and the PATH variable to find the scripts (posy_one,
posy_static).

Therefore you will need to change:
your path, to include /home/fred/perl/script (where the script will be)

	PATH=/home/fred/perl/script:${PATH}

the PERL5LIB variable to add /home/fred/perl/lib

	PERL5LIB=/home/fred/perl/lib:${PERL5LIB}

=head1 REQUIRES

    Posy
    Posy::Core
    Posy::Plugin::YamlConfig

    Test::More

=head1 SEE ALSO

perl(1).
Posy
YAML

=head1 BUGS

Please report any bugs or feature requests to the author.

=head1 AUTHOR

    Kathryn Andersen (RUBYKAT)
    perlkat AT katspace dot com
    http://www.katspace.com

=head1 COPYRIGHT AND LICENCE

Copyright (c) 2004-2005 by Kathryn Andersen

Original 'dynamiccss' blosxom plugin copyright (c) 2004 by Brian Haberer
http://www.canonical.org/~brian/software/dynamiccss

This program is free software; you can redistribute it and/or
modify it under the terms of the GNU General Public License
as published by the Free Software Foundation; either version 2
of the License, or (at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.

Or See: http://www.gnu.org/copyleft/gpl.html

=cut

1; # End of Posy::Plugin::DynamicCss
__END__
