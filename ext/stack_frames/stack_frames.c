#include "deps.h"
#include "frame.h"
#include "buffer.h"

RUBY_FUNC_EXPORTED void Init_stack_frames(void) {
    VALUE mStackFrames = rb_define_module("StackFrames");
    stack_buffer_define(mStackFrames);
    stack_frame_define(mStackFrames);
}
