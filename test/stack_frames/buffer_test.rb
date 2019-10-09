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
    buffer = StackFrames::Buffer.new(1)
    expected_line = __LINE__ + 1
    frames_length = buffer.capture
    assert_equal(1, frames_length)
    frame = buffer[0]
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
    num_allocations = count_allocations do
      buffer.capture
      frame = buffer[1]
      got_path = frame.path
      got_lineno = frame.lineno
      got_method_name = frame.method_name
    end
    assert_equal(0, num_allocations)
    assert_equal('count_allocations', got_method_name)
    assert_equal(method(:count_allocations).source_location[1] + 1, got_lineno)
    assert_equal(__FILE__, got_path)
  end

  private

  def count_allocations(&block)
    StackProf.run(mode: :object, &block)[:samples]
  end

  def buffer_frames(buffer)
    frames = []
    buffer.each { |frame| frames << frame }
    frames
  end
end
