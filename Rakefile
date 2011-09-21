require 'jeweler'

Jeweler::Tasks.new do |s|
	s.name = "clockworkd"
	s.summary = "A scheduler process to replace cron."
	s.description = "A scheduler process to replace cron, using a more flexible Ruby syntax running as a single long-running process.  Inspired by rufus-scheduler and resque-scheduler."
	s.author = "Adam Wiggins"
	s.email = "adam@heroku.com"
	s.homepage = "http://github.com/arufanov/clockworkd"
	s.executables = [ "clockworkd" ]
	s.rubyforge_project = "clockworkd"

	s.files = FileList["[A-Z]*", "{bin,lib}/**/*"]
end

Jeweler::GemcutterTasks.new

task 'test' do
	sh "ruby spec/lib/clockworkd_spec.rb"
end

task :build => :test
