#!/usr/bin/perl

use strict;
use warnings;
use utf8;

use XMLRPC::Lite;
use Config::Simple;
use File::Temp qw(tempfile);
use File::Copy;

my $config_file = $ENV{'HOME'} . '/etc/release-support.conf';
my $config = new Config::Simple($config_file);

die "require argument. $0 <product> <version>\n" if scalar @ARGV < 2;

my $product = $ARGV[0];
my $version = $ARGV[1];
print $config->param($product . '.productname'), "\n";
print $version, "\n";

sub get_conf {
    my $name = shift;
    return $config->param("$product.$name");
}
sub message {
    my ($version) = @_;
    my @urls = get_conf('urls');
    my $title = get_conf('title');
    $title =~ s/{VERSION}/$version/g;
    print $title, "\n";
    my $template_prefix = get_conf('template_prefix');
    $template_prefix =~ s/{VERSION}/$version/g;
    my $template_suffix = get_conf('template_suffix');
    $template_suffix =~ s/{VERSION}/$version/g;
    my($tmp_fh, $tmp_filename) = tempfile();
    close $tmp_fh;
    my $change_log = get_conf('change_log');
    copy $change_log, $tmp_filename if $change_log;
    my $editor = $ENV{'EDITOR'} || 'vi';
    system "$editor $tmp_filename";
    open my $points_handle, '<', $tmp_filename or die "$tmp_filename: $!\n";
    my $points = do {local $/; <$points_handle>};
    return {
        urls => \@urls,
        title => $title,
        template_prefix => $template_prefix,
        points => $points,
        template_suffix => $template_suffix,
    };
}

sub html_format {
    my $html = shift;

    $html =~ s@(https?://[^ \n]+)@<a href="$1">$1</a>@gs;
    return $html;
}
sub display_message {
    use HTML::Entities;

    my ($message, $type) = @_;
    print "----------------------------------------------------------------------\n";
    print "$type\n";
    print "----------------------------------------------------------------------\n";
    my $title = $message->{title};
    my $template_prefix = $message->{template_prefix};
    my $template_suffix = $message->{template_suffix};
    my $points = $message->{points};
    if ($type eq 'html') {
        $title = encode_entities($title, '<>&"');
        $template_prefix = encode_entities($template_prefix, '<>&"');
        $template_prefix = html_format($template_prefix);
        $template_suffix = encode_entities($template_suffix, '<>&"');
        $template_suffix = html_format($template_suffix);
        $points = encode_entities($points, '<>&"');
    }
    print <<"EOC";
$title

$template_prefix
$points
$template_suffix
EOC
}
my $message = message($version);
print "notify urls\n";
print " - $_\n" for @{$message->{urls}};
display_message($message, 'text');
display_message($message, 'html');

sub post_wordpress {
    my $result = XMLRPC::Lite
        -> proxy('http://example.com/xmlrpc.php')
        -> call('metaWeblog.newPost', 1, 'ログインID', 'パスワード', {
            'title' => XMLRPC::Data->type('string', 'タイトルです'),
            'categories' => ['news'],
            'description' => XMLRPC::Data->type('string', "本文です<br />二行目"),
        }, 1) -> result;
}
