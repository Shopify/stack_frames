#include "deps.h"

typedef struct {
    VALUE buffer;
    int index;
} frame_t;

VALUE frame_new(VALUE frame_buffer, int index);
void init_frame(VALUE mStackFrames);
