#!/usr/bin/env ruby

# encoding: utf-8

require 'rubygems'
require 'daemon-spawn'

RAILS_ROOT = File.expand_path(File.join(File.dirname(__FILE__), '../../../..'))

process_title = "delayed_job: "+RAILS_ROOT
$0 = process_title

class DelayedJobWorker < DaemonSpawn::Base
  def start(args)
    ENV['RAILS_ENV'] ||= args.first || 'development'
    Dir.chdir RAILS_ROOT
    require File.join('config', 'environment')
    Delayed::Worker.new.start
  end

  def stop
    system("kill `cat #{RAILS_ROOT}/tmp/pids/delayed_job.pid`")
  end
end

DelayedJobWorker.spawn!(:log_file => File.join(RAILS_ROOT, "log", "delayed_job.log"),
                        :pid_file => File.join(RAILS_ROOT, 'tmp', 'pids', 'delayed_job.pid'),
                        :sync_log => true,
                        :working_dir => RAILS_ROOT)
