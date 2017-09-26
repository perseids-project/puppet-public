SSH = 'ssh -t -A'
IDENTITY = '-i ../perseidskey.pem'
SSH_UBUNTU = "ssh -t -A #{IDENTITY} -l ubuntu -p 22"
KEYID = "0DBB3AFE"

desc "Bootstrap Puppet on ENV['CLIENT'] using branch ENV['BRANCH'] in environment ENV['PERSEIDS_ENV']"
task :bootstrap do
  client = ENV['CLIENT']
  branch = ENV['BRANCH'] || "master"
  environment = ENV['PERSEIDS_ENV'] || "development"
  hostname = ENV['HOSTNAME'] || "unset"
  if hostname == "unset"
    puts "Hostname must be set with HOSTNAME="
    exit 1
  end
  puts "Copying deploy key..."
  system "scp #{IDENTITY} -oStrictHostKeyChecking=no ./site-modules/site/files/profiles/git.priv ubuntu@#{client}:.ssh/id_rsa"
  puts "done."
  puts "Copying bootstrap script..."
  system "scp #{IDENTITY} -oStrictHostKeyChecking=no ./bootstrap/bootstrap.sh ubuntu@#{client}:/tmp"
  puts "done."
  puts "Copying decryption key..."
  system "gpg --export-secret-subkeys --export-options export-reset-subkey-passwd -a #{KEYID} | #{SSH_UBUNTU} #{client} 'HOME=/root sudo gpg --import'"
  puts "done."
  puts "Bootstrapping..."
  sh "#{SSH_UBUNTU} #{client} sudo bash /tmp/bootstrap.sh #{hostname} #{branch} #{environment}"
  puts "done."
end

desc "Add lint/syntax check hook to your git repo"
task :add_hook do
  here = File.dirname(__FILE__)
  sh "ln -s #{here}/hooks/pre-commit #{here}/.git/hooks/pre-commit"
  puts "Puppet lint/syntax check hook added"
end

require 'rubygems'

desc "Run puppet-lint"
task :lint do
  begin
    gem 'puppet-lint', '>=2.0.0'
    require 'puppet-lint'
  rescue LoadError
    fail "Please 'gem install puppet-lint'"
  end
  puts 'Running lint check...'
  PuppetLint.configuration.with_filename = true
  PuppetLint.configuration.send("disable_140chars")
  PuppetLint.configuration.send("disable_documentation")
  PuppetLint.configuration.send('disable_quoted_booleans')
  PuppetLint.configuration.ignore_paths = ['site-modules/tomcat/**/*.pp']
  if ENV['lintfix']=='yes'
    PuppetLint.configuration.fix = true
  end
  PuppetLint::OptParser.build

  RakeFileUtils.send(:verbose, true) do
    linter = PuppetLint.new
    matched_files = FileList['**/*.pp']

    if ignore_paths = PuppetLint.configuration.ignore_paths
      matched_files = matched_files.exclude(*ignore_paths)
    end

    matched_files.to_a.each do |puppet_file|
      linter.file = puppet_file
      linter.run
      linter.print_problems
      if PuppetLint.configuration.fix && !linter.problems.any? { |e| e[:check] == :syntax }
        File.open(puppet_file, 'w') do |fd|
          fd.write linter.manifest
        end
      end
    end

    stats = "#{linter.statistics[:error]} error(s), #{linter.statistics[:warning]} warning(s)"
    if linter.errors? || (linter.warnings? && PuppetLint.configuration.fail_on_warnings)
      puts "Lint check failed: #{stats}"
    else
      puts "Lint check passed: #{stats}"
    end
  end
end

desc "Run puppet-lint and fix problems automatically"
task :lintfix do
  ENV['lintfix']='yes'
  Rake::Task['lint'].invoke
end
