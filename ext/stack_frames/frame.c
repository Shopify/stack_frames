#include "frame.h"
#include "buffer.h"

typedef struct {
    VALUE buffer;
    int index;
} frame_t;

VALUE cFrame;

static void frame_mark(void *ptr)
{
    frame_t *frame = ptr;
    rb_gc_mark(frame->buffer);
}

static size_t frame_memsize(const void *ptr)
{
    return sizeof(frame_t);
}

const rb_data_type_t frame_data_type = {
    "stack_frames_frame",
    { frame_mark, RUBY_DEFAULT_FREE, frame_memsize, },
    NULL, NULL, RUBY_TYPED_FREE_IMMEDIATELY
};

VALUE stack_frame_new(VALUE frame_buffer, int index) {
    frame_t *frame;
    VALUE obj = TypedData_Make_Struct(cFrame, frame_t, &frame_data_type, frame);
    frame->buffer = frame_buffer;
    frame->index = index;
    return obj;
}

static VALUE frame_allocate(VALUE klass) {
    rb_raise(rb_eRuntimeError, "frames cannot be allocated manually");
    return Qnil;
}

static VALUE frame_profile_frame(VALUE self) {
    frame_t *frame;
    TypedData_Get_Struct(self, frame_t, &frame_data_type, frame);
    return stack_buffer_profile_frame(frame->buffer, frame->index);
}

static VALUE frame_lineno(VALUE self) {
    frame_t *frame;
    TypedData_Get_Struct(self, frame_t, &frame_data_type, frame);
    return INT2NUM(stack_buffer_frame_lineno(frame->buffer, frame->index));
}

#define DEFINE_FRAME_ACCESSOR(func_name) \
    static VALUE frame_##func_name(VALUE self) { \
        return rb_profile_frame_##func_name(frame_profile_frame(self)); \
    }

DEFINE_FRAME_ACCESSOR(path)
DEFINE_FRAME_ACCESSOR(absolute_path)
DEFINE_FRAME_ACCESSOR(label)
DEFINE_FRAME_ACCESSOR(base_label)
DEFINE_FRAME_ACCESSOR(full_label)
DEFINE_FRAME_ACCESSOR(first_lineno)
DEFINE_FRAME_ACCESSOR(classpath)
DEFINE_FRAME_ACCESSOR(singleton_method_p)
DEFINE_FRAME_ACCESSOR(method_name)
DEFINE_FRAME_ACCESSOR(qualified_method_name)

void stack_frame_define(VALUE mStackFrames) {
    cFrame = rb_define_class_under(mStackFrames, "Frame", rb_cObject);
    rb_global_variable(&cFrame);

    rb_define_alloc_func(cFrame, frame_allocate);
    rb_define_method(cFrame, "lineno", frame_lineno, 0);
    rb_define_method(cFrame, "path", frame_path, 0);
    rb_define_method(cFrame, "absolute_path", frame_absolute_path, 0);
    rb_define_method(cFrame, "label", frame_label, 0);
    rb_define_method(cFrame, "base_label", frame_base_label, 0);
    rb_define_method(cFrame, "full_label", frame_full_label, 0);
    rb_define_method(cFrame, "first_lineno", frame_first_lineno, 0);
    rb_define_method(cFrame, "classpath", frame_classpath, 0);
    rb_define_method(cFrame, "singleton_method?", frame_singleton_method_p, 0);
    rb_define_method(cFrame, "method_name", frame_method_name, 0);
    rb_define_method(cFrame, "qualified_method_name", frame_qualified_method_name, 0);
}
