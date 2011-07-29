#!/usr/bin/perl

#--------------------------------------------------------------------
# Credits, fluff, etc
#--------------------------------------------------------------------
#
# I've been using irssi for a while, and have just got a MacBookPro
# and wanted to continue to use irssi for irc.
# I found that I was missing mentions and PMs when on another workspace,
# and wanted some way of getting notified.
# Google led me to this:
# http://matthewhutchinson.net/2010/8/21/irssi-screen-fnotify-and-growl-on-osx
# which in turn, linked to fnotify, written by Thorsten Leemhuis
# (fedora@leemhuis.info, http://www.leemhuis.info/files/fnotify/).
#
# I wanted something that would interact with Growl, preferably, but
# decided to skip the writing it to disk steps mentioned above, and modified
# his fnotify script to use Net::Growl
#
# The fnotify credits are here, for continuity...
#
# In parts based on knotify.pl 0.1.1 by Hugo Haas
# http://larve.net/people/hugo/2005/01/knotify.pl
# which is based on osd.pl 0.3.3 by Jeroen Coekaerts, Koenraad Heijlen
# http://www.irssi.org/scripts/scripts/osd.pl
#
# Other parts based on notify.pl from Luke Macken
# http://fedora.feedjack.org/user/918/
#

#--------------------------------------------------------------------
# ...on with the code...
#--------------------------------------------------------------------

use strict;
use vars qw($VERSION %IRSSI);
use lib '/Library/Perl/5.10.0';

use Net::Growl;

use Irssi;
$VERSION = '0.1';
%IRSSI = (
	authors     => 'Karl Dyson',
	contact     => 'hackery@perlbitch.com',
	name        => 'growl',
	description => 'Growl mentions and PMs.',
	url         => 'http://perlbitch.com/growl.pl',
	license     => 'GNU General Public License',
	changed     => '$Date: 2011-07-29 16:00:00 +0100 (Fri, 29 Jul 2011) $'
);

#--------------------------------------------------------------------
# Config settings
#--------------------------------------------------------------------
#
# You can /set growl_password and/or growl_host if you want/need...

my %config;

Irssi::settings_add_str('growl', 'growl_host' => 'localhost');
$config{'growl_host'} = Irssi::settings_get_str('growl_host');
$config{'growl_host'} ||= 'localhost';

Irssi::settings_add_str('growl', 'growl_password' => 'growl');
$config{'growl_password'} = Irssi::settings_get_str('growl_password');
$config{'growl_password'} ||= undef;

#--------------------------------------------------------------------
# Register With Growl
#--------------------------------------------------------------------

register(
	host => $config{'growl_host'},
	application => 'irssi',
	password => $config{'growl_password'},
);

#--------------------------------------------------------------------
# Private message parsing
#--------------------------------------------------------------------

sub priv_msg {
	my ($server,$msg,$nick,$address,$target) = @_;
	growl($nick." " .$msg );
}

#--------------------------------------------------------------------
# Printing hilight's
#--------------------------------------------------------------------

sub hilight {
    my ($dest, $text, $stripped) = @_;
    if ($dest->{level} & MSGLEVEL_HILIGHT) {
	growl($dest->{target}. " " .$stripped );
    }
}

#--------------------------------------------------------------------
# The actual growling
#--------------------------------------------------------------------

sub growl {
	my ($text) = @_;
	my($nick, $message) = $text =~ m/^(\S+)\s(.*)$/;
	notify(
		application => 'irssi',
		title => $nick,
		description => $message,
		priority => 2,
		sticky => 'False',
		password => 'smirk',
	);
}

#--------------------------------------------------------------------
# Irssi::signal_add_last / Irssi::command_bind
#--------------------------------------------------------------------

Irssi::signal_add_last("message private", "priv_msg");
Irssi::signal_add_last("print text", "hilight");

#- end
