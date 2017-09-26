#!/usr/bin/ruby

require 'find'
require 'time'
require 'date'

usage="Usage: #{$PROGRAM_NAME} [--gc] START\n\nFind and fsck all Git repos under the directory START (and optionally `git gc` them)."

@gc = false
if ARGV[0] == '--gc'
  @gc = true
  ARGV.shift
end
START=ARGV[0] || fail(usage)

ERROR = /error|fatal|unreachable|missing|sha1 mismatch/
@skipped, @ok, @critical = 0, 0, 0

def log(message)
  puts "#{Time.now.iso8601} -- #{message}"
end

def fsck(path)
  message = "Checking #{path}..."
  log "#{message}"
  status = "OK"
  errors = []
  command = %[git --git-dir="#{path}" for-each-ref --sort=-creatordate --count=1 --format="%(creatordate)" refs/heads/]
  output = `#{command}`.chomp
  if $?.exitstatus != 0
    status = "CRITICAL"
    @critical += 1
  else
    last_commit_date = Date.parse(`#{command}`.chomp)
    days_since_last_commit = Date.today - last_commit_date
    if days_since_last_commit < 180
      command = %[echo git --git-dir="#{path}" fsck --full 2>&1]
      output = `#{command}`.chomp
      if output =~ ERROR
	errors = output.split(/\n/).grep(ERROR)
	# Discard any errors relating to 'refs/remotes'
	errors -= errors.grep(/refs\/remotes/)
	if errors.length > 0
	  status = "CRITICAL"
	  @critical += 1
	end
      else
	@ok += 1
	if @gc
	  log "GCing #{path}"
	  gc_command = %[git --git-dir="#{path}" gc]
	  system(gc_command)
	end
      end
    else
      status = "skipped"
      @skipped += 1
    end
    log "#{status} #{path}"
    errors.each do |error|
      log error
    end
  end
end

log "#{$PROGRAM_NAME} started at #{START} (GC #{@gc ? 'enabled' : 'disabled' })"
Find.find(START) do |path|
  if FileTest.directory?(path) and path =~ /.git$/
    fsck(path)
  end
end
log "Stats: #{@skipped} skipped, #{@critical} critical, #{@ok} OK"
log "#{$PROGRAM_NAME} finished at #{START}"
