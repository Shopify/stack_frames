#include "deps.h"

typedef struct {
    VALUE *profile_frames;
    VALUE *frames;
    int *lines;
    int length, capacity;
} buffer_t;

VALUE buffer_profile_frame(VALUE buffer, int index);
int buffer_frame_lineno(VALUE buffer, int index);
void init_buffer(VALUE mStackFrames);
