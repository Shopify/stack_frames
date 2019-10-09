require "test_helper"

class StackFrames::FrameTest < Minitest::Test
  def test_allocation_from_ruby_not_allowed
    exc = assert_raises(RuntimeError) do
      StackFrames::Frame.allocate
    end
    assert_equal("frames cannot be allocated manually", exc.message)
  end

  def test_new_is_private
    assert_raises(NoMethodError) do
      StackFrames::Frame.new
    end
  end
end
