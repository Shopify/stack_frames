#include "deps.h"
#include "frame.h"
#include "buffer.h"

VALUE mStackFrames;

void Init_stack_frames() {
    mStackFrames = rb_define_module("StackFrames");
    init_buffer(mStackFrames);
    init_frame(mStackFrames);
}
