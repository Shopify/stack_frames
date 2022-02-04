# frozen_string_literal: true
require "test_helper"

class StackFrames::BufferTest < Minitest::Test
  def test_new
    buffer = StackFrames::Buffer.new(4)
    assert_equal(4, buffer.capacity)
    assert_equal(0, buffer.length)
    assert_nil(buffer[0])
    buffer.each { flunk("unexpected yield") }
  end

  def test_new_with_invalid_capacity
    [-1, 0].each do |invalid_capacity|
      exc = assert_raises(ArgumentError) { StackFrames::Buffer.new(invalid_capacity) }
      assert_equal("non-positive buffer capacity", exc.message)
    end
  end

  def test_capture
    buffer = StackFrames::Buffer.new(2)
    expected_line = __LINE__ + 1
    frames_length = buffer.capture
    assert_equal(2, frames_length)
    frame = buffer[RUBY_VERSION >= "3" ? 1 : 0]
    assert_equal('test_capture', frame.method_name)
    assert_equal(true, frame.method_name.frozen?)
    assert_equal(__FILE__, frame.path)
    assert_equal(true, frame.path.frozen?)
    assert_equal(expected_line, frame.lineno)
    assert_equal(method(__method__).source_location[1], frame.first_lineno)
    assert_equal(false, frame.singleton_method?)
  end

  def test_no_object_allocations
    buffer = StackFrames::Buffer.new(10)
    got_path = nil
    got_lineno = nil
    got_method_name = nil
    offset = RUBY_VERSION >= "3" ? 2 : 1
    num_allocations = count_allocations do
      buffer.capture
      frame = buffer[offset]
      got_path = frame.path
      got_lineno = frame.lineno
      got_method_name = frame.method_name
    end
    assert_equal(RUBY_VERSION >= "3" ? 1 : 0, num_allocations)
    assert_equal('count_allocations', got_method_name)
    assert_equal(method(:count_allocations).source_location[1] + 3, got_lineno)
    assert_equal(__FILE__, got_path)
  end

  def test_index_lookup
    buffer = StackFrames::Buffer.new(10)
    capture_lineno = __LINE__ + 2
    frame1 do
      buffer.capture
    end
    [
      ["test_index_lookup", capture_lineno],
      ["frame1", method(:frame1).source_location[1] + 1],
      ["test_index_lookup", capture_lineno - 1],
    ].each_with_index do |(method_name, lineno), i|
      i += 1 if RUBY_VERSION >= "3"
      frame = buffer[i]
      assert_equal(method_name, frame.method_name, "frame #{i}")
      assert_equal(lineno, frame.lineno, "frame #{i}")
    end
    assert_nil(buffer[-1])
    assert_nil(buffer[buffer.length])
  end

  def test_each
    buffer = StackFrames::Buffer.new(10)
    frame2 do
      frame1 do
        buffer.capture
      end
    end
    i = 0
    buffer.each do |frame|
      assert_same(frame, buffer[i])
      i += 1
    end
    assert_equal(buffer.length, i)
  end

  def test_find
    buffer = StackFrames::Buffer.new(10)
    frame2 do
      frame1 do
        buffer.capture
      end
    end
    frame = buffer.find { |frame| frame.method_name == "frame2" }
    assert_equal(method(:frame2).source_location[1] + 1, frame.lineno)

    assert_same(buffer[0], buffer.find { |frame| true })

    assert_nil(buffer.find { |frame| false })
  end

  private

  def frame1
    yield
  end

  def frame2
    yield
  end

  def count_allocations(&block)
    yield # run the block once to warm method and cost caches
    before = GC.stat(:total_allocated_objects)
    yield
    GC.stat(:total_allocated_objects) - before
  end
end
