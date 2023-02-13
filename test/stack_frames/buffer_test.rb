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
    frame = buffer[skipping_c_frames? ? 0 : 1]
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
    frame_index = skipping_c_frames? ? 1 : 3
    instrumented_code = lambda do
      buffer.capture
      frame = buffer[frame_index]
      got_path = frame.path
      got_lineno = frame.lineno
      got_method_name = frame.method_name
    end
    count_allocations(&instrumented_code) # allow lazy memoized allocations
    num_allocations = count_allocations(&instrumented_code)
    assert_equal(0, num_allocations)
    assert_equal('count_allocations', got_method_name)
    assert_equal(method(:count_allocations).source_location[1] + 1, got_lineno)
    assert_equal(__FILE__, got_path)
  end

  def test_index_lookup
    buffer = StackFrames::Buffer.new(10)
    capture_lineno = __LINE__ + 2
    frame1 do
      buffer.capture
    end
    skipped = 0
    [
      [:c, "capture", 0],
      [:ruby, "test_index_lookup", capture_lineno],
      [:ruby, "frame1", method(:frame1).source_location[1] + 1],
      [:ruby, "test_index_lookup", capture_lineno - 1],
    ].each_with_index do |(lang, method_name, lineno), i|
      if skipping_c_frames? && lang == :c
        skipped += 1
        next
      end
      buffer_idx = i - skipped
      frame = buffer[buffer_idx]
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

  def test_gc_stress
    GC.stress = true
    StackFrames::Buffer.new(10)
  ensure
    GC.stress = false
  end

  def test_frame_invalidated_from_recapture
    buffer = StackFrames::Buffer.new(100)
    frame1 do
      buffer.capture
    end
    last_index = buffer.length - 1
    frame = buffer[last_index]
    buffer.capture
    exc = assert_raises(RuntimeError) { frame.method_name }
    assert_match(/\AStack frame is no longer valid,/, exc.message)
    exc2 = assert_raises(RuntimeError) { frame.lineno }
    assert_equal(exc.message, exc2.message)
  end

  private

  def skipping_c_frames?
    Gem::Version.new(RUBY_VERSION) < Gem::Version.new("3")
  end

  def frame1
    yield
  end

  def frame2
    yield
  end

  def count_allocations(&block)
    StackProf.run(mode: :object, &block)[:samples]
  end
end
