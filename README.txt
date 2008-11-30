CI::Reporter is an add-on to Test::Unit and RSpec that allows you to generate XML reports of your test and/or spec runs. The resulting files can be read by a continuous integration system that understands Ant's JUnit report XML format, thus allowing your CI system to track test/spec successes and failures.

== Dependencies

CI::Reporter has one required dependency on Builder, but since many will have a viable version of Builder via Rails' ActiveSupport gem, Builder is not a direct dependency of the project at the moment.  Instead, ensure that you have either the +builder+ or +activesupport+ gem installed before continuing.  CI::Reporter will raise an exception at runtime if it cannot locate Builder.

== Installation

CI::Reporter is available as a gem. To install the gem, use the usual gem command:

    gem install ci_reporter

To use CI::Reporter as a Rails plugin, first install the gem, and then install the plugin as follows:

    script/plugin install http://svn.caldersphere.net/svn/main/plugins/ci_reporter

== Usage

CI::Reporter works best with projects that use a +Rakefile+ along with the standard <code>Rake::TestTask</code> or <code>Spec::Rake::SpecTask</code> tasks for running tests or examples, respectively. In this fashion, it hooks into <code>Test::Unit</code> or +RSpec+ using environment variables recognized by these custom tasks to inject the CI::Reporter code into the test or spec runs.  If you're using the Rails plugin, step 1 is unnecessary; skip to step 2.

1. To use CI::Reporter, simply add the following lines to your Rakefile:

    require 'rubygems'
    gem 'ci_reporter'
    require 'ci/reporter/rake/rspec' # use this if you're using RSpec
    require 'ci/reporter/rake/test_unit' # use this if you're using Test::Unit

2. Next, either modify your Rakefile to make the <code>ci:setup:rspec</code> or <code>ci:setup:testunit</code> task a dependency of your test tasks, or include them on the Rake command-line before the name of the task that runs the tests or specs.

    rake ci:setup:testunit test

Report files are written, by default, to the <code>test/reports</code> or <code>spec/reports</code> subdirectory of your project.  If you wish to customize the location, simply set the environment variable CI_REPORTS (either in the environment, on the Rake command line, or in your Rakefile) to the location where they should go.

== Advanced Usage

If you don't have control over the Rakefile or don't want to modify it, CI::Reporter has a substitute rake file that you can specify on the command-line.  It assumes that the main project rake file is called +Rakefile+ and lives in the current directory.  Run like so:

    rake -f GEM_PATH/stub.rake ci:setup:testunit test
    rake -f GEM_PATH/stub.rake ci:setup:rspec spec

If for some reason you can't use the above technique to inject CI::Reporter (e.g., you're not using Rake), you'll have to do one of these:

1. If you're using <code>Test::Unit</code>, ensure the <code>ci/reporter/rake/test_unit_loader.rb</code> file is loaded or required at some point before the tests are run.
2. If you're using +RSpec+, you'll need to pass the following arguments to the +spec+ command:
    --require GEM_PATH/lib/ci/reporter/rake/rspec_loader
    --format CI::Reporter::RSpec

There's a bit of a chicken and egg problem because rubygems needs to be loaded before you can require any CI::Reporter files.  If you cringe hard-coding a full path to a specific version of the gem, you can also copy the +rspec_loader+ file into your project and require it directly -- the contents are version-agnostic and are not likely to change in future releases.

== Environment Variables

* +CI_REPORTS+: if set, points to a directory where report files will be written.
* +CI_CAPTURE+: if set to value "off", stdout/stderr capture will be disabled.

== Source

You can get the CI::Reporter source using Git, in any of the following ways:

    git clone http://git.caldersphere.net/ci_reporter.git
    git clone git://github.com/nicksieger/ci_reporter.git

You can also download a tarball of the latest CI::Reporter source at http://github.com/nicksieger/ci_reporter/tree/master.

== License

This software is released under an MIT license.  For details, see the LICENSE.txt file included with the distribution.  The software is copyright (c) 2006-2007 Nick Sieger <nicksieger@gmail.com>.
