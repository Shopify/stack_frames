require "bundler/gem_tasks"
require "rake/testtask"
require 'rake/extensiontask'

ENV['STACK_FRAMES_DEV'] = '1'

Rake::ExtensionTask.new("stack_frames") do |ext|
  ext.lib_dir = 'lib/stack_frames'
end

Rake::TestTask.new(test: :compile) do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end

task :default => :test
