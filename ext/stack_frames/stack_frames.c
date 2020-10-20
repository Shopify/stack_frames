#include "deps.h"
#include "frame.h"
#include "buffer.h"

void Init_stack_frames() {
    VALUE mStackFrames = rb_define_module("StackFrames");
    stack_buffer_define(mStackFrames);
    stack_frame_define(mStackFrames);
}
