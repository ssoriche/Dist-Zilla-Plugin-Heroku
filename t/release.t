use strict;
use warnings;
 
use Dist::Zilla  1.093250;
use Dist::Zilla::Tester;
use Cwd          qw{ getcwd  };
use File::Temp   qw{ tempdir };
use Git::Wrapper;
use Path::Class;
use Test::More;
use version;
 
# Mock HOME to avoid ~/.gitexcludes from causing problems
$ENV{HOME} = tempdir( CLEANUP => 1 );
 
# build fake repository
my $zilla = Dist::Zilla::Tester->from_config({
  dist_root => dir('corpus/release')->absolute,
});
 
chdir $zilla->tempdir->subdir('source');
system "git init";
my $git = Git::Wrapper->new('.');
 
my ($version) = $git->version =~ m[^( \d+ \. \d+ \. \d+ )]x;
my $gitversion = version->parse( $version );
if ( $gitversion < version->parse('1.7.0') ) {
    plan skip_all => 'git 1.7.0 or later required for this test';
} else {
    plan tests => 1;
}
 
$git->config( 'user.name'  => 'dzp-heroku test' );
$git->config( 'user.email' => 'dzp-heroku@test' );
$git->add( qw{ dist.ini Changes } );
$git->commit( { message => 'initial commit' } );

# create a clone, and use it to set up origin
my $clone = tempdir( CLEANUP => 1 );
my $curr  = getcwd;
$git->clone( { quiet=>1, 'no-checkout'=>1, bare=>1 }, $curr, $clone );
$git->remote('add', 'heroku', $clone);
$git->config('branch.master.remote', 'heroku');
$git->config('branch.master.merge', 'refs/heads/master');
 
# do the release
append_to_file('Changes',  "\n");
append_to_file('dist.ini', "\n");
$git->add( qw{ dist.ini Changes } );
$git->commit( { message => 'Ready for release' } );
$zilla->release;
 
# check if everything was pushed
$git = Git::Wrapper->new( $clone );
my ($log) = $git->log( 'HEAD' );
is($log->message,"Ready for release\n");
 
sub append_to_file {
    my ($file, @lines) = @_;
    open my $fh, '>>', $file or die "can't open $file: $!";
    print $fh @lines;
    close $fh;
}
