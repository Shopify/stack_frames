require "bundler/gem_tasks"
require "rake/testtask"
require 'rake/extensiontask'
require "ruby_memcheck"

RubyMemcheck.config(binary_name: "stack_frames")

ENV['STACK_FRAMES_DEV'] = '1'

Rake::ExtensionTask.new("stack_frames") do |ext|
  ext.lib_dir = 'lib/stack_frames'
end

test_config = lambda do |t|
  t.libs << "test"
  t.libs << "lib"
  t.test_files = FileList["test/**/*_test.rb"]
end
Rake::TestTask.new(test: :compile, &test_config)
namespace :test do
  RubyMemcheck::TestTask.new(valgrind: :compile, &test_config)
end

task :default => :test
