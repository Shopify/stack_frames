# StackFrames

This library allows backtraces to be captured and accessed without
object allocations by leveraging MRI's profile frames API.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'stack_frames'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install stack_frames

## Usage

Pre-allocate a buffer to use for capturing stack frames, then re-use that buffer
to capture the backtrace multiple times.

```ruby
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
```

If stack frames need to be captured in multiple threads, then access
to the buffer can either be synchronized using a Mutex or a per-thread
buffer could be created and stored in a thread-local variable.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/Shopify/stack_frames.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
