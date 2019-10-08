# frozen_string_literal: true

require 'bundler/setup'
require 'benchmark/ips'
require 'stack_frames'

STACK_FRAMES_CALLER_BUFFER = StackFrames::Buffer.new(2)
STACK_FRAMES_BUFFER = StackFrames::Buffer.new(2048)
LOCK = Mutex.new
Thread.current.thread_variable_set(:stack_frames_buffer, STACK_FRAMES_BUFFER)

Benchmark.ips do |bench|
  bench.report("caller(1, 1)") do
    caller(1, 1).first
  end
  bench.report("caller_locations(1, 1)") do
    caller_locations(1).first.path
  end
  bench.report("stack_frames caller frame") do
    buffer = STACK_FRAMES_CALLER_BUFFER
    buffer.capture
    buffer[1].path
  end
  bench.report("caller") do
    caller.first
  end
  bench.report("caller_locations") do
    caller_locations.first.path
  end
  bench.report("stack_frames capture stack") do
    buffer = STACK_FRAMES_BUFFER
    buffer.capture
    buffer[1].path
  end
  bench.report("stack_frames synchronized capture") do
    LOCK.synchronize do
      buffer = STACK_FRAMES_BUFFER
      buffer.capture
      buffer[1].path
    end
  end
  bench.report("stack_frames thread-local capture") do
    buffer = Thread.current.thread_variable_get(:stack_frames_buffer)
    buffer.capture
    buffer[1].path
  end
end
