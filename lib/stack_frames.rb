# frozen_string_literal: true

require 'stack_frames/version'
require 'stack_frames/stack_frames'

StackFrames::Frame.singleton_class.class_eval do
  private(:new)
end
