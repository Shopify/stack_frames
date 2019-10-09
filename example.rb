# example.rb
require 'stack_frames'

STACK_FRAMES_BUFFER = StackFrames::Buffer.new(2)
CAPTURE_CALLER = -> { STACK_FRAMES_BUFFER.capture }

def foo(&block)
  yield
end

foo(&CAPTURE_CALLER)
caller_frame = STACK_FRAMES_BUFFER[1]
p caller_frame.path # => "example.rb"
p caller_frame.lineno # => 14
p caller_frame.method_name # => "foo"
puts

CAPTURE_CALLER.call
p caller_frame.path # => "example.rb"
p caller_frame.lineno # => 18
p caller_frame.method_name # => nil
