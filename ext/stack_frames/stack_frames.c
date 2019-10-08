#include "deps.h"
#include "frame.h"
#include "buffer.h"

VALUE mStackFrames;

void Init_stack_frames() {
    mStackFrames = rb_define_module("StackFrames");
    stack_buffer_define(mStackFrames);
    stack_frame_define(mStackFrames);
}
