# frozen_string_literal: true

require 'stack_frames/version'

begin
  ruby_version = /(\d+\.\d+)/.match(RUBY_VERSION)
  require "stack_frames/#{ruby_version}/stack_frames"
rescue LoadError
  require "stack_frames/stack_frames"
end

StackFrames::Frame.singleton_class.class_eval do
  private(:new)
end
