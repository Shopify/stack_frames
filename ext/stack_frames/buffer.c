#include "buffer.h"
#include "frame.h"

typedef struct {
    VALUE *profile_frames;
    VALUE *frames;
    int *lines;
    int length, capacity;
} buffer_t;

static void buffer_mark(void *ptr)
{
    buffer_t *buffer = ptr;

    for (int i = 0; i < buffer->length; i++) {
        rb_gc_mark(buffer->profile_frames[i]);
    }
    for (int i = 0; i < buffer->capacity; i++) {
        rb_gc_mark(buffer->frames[i]);
    }
}

static void buffer_free(void *ptr)
{
    buffer_t *buffer = ptr;
    ruby_xfree(buffer->profile_frames);
    ruby_xfree(buffer->frames);
    ruby_xfree(buffer->lines);
}

static size_t buffer_memsize(const void *ptr)
{
    return sizeof(buffer_t);
}

const rb_data_type_t buffer_data_type = {
    "stack_frames_buffer",
    { buffer_mark, buffer_free, buffer_memsize, },
    NULL, NULL, RUBY_TYPED_FREE_IMMEDIATELY
};

static VALUE buffer_allocate(VALUE klass) {
    VALUE obj;
    buffer_t *buffer;

    obj = TypedData_Make_Struct(klass, buffer_t, &buffer_data_type, buffer);
    return obj;
}

static VALUE buffer_initialize(VALUE self, VALUE size) {
    int capacity = NUM2INT(size);
    buffer_t *buffer;

    if (capacity <= 0) {
        rb_raise(rb_eArgError, "non-positive buffer capacity");
    }

    TypedData_Get_Struct(self, buffer_t, &buffer_data_type, buffer);
    buffer->profile_frames = ALLOC_N(VALUE, capacity);
    buffer->lines = ALLOC_N(int, capacity);
    buffer->frames = ALLOC_N(VALUE, capacity);

    buffer->capacity = 0;
    for (int i = 0; i < capacity; i++) {
        buffer->frames[i] = stack_frame_new(self, i);
        buffer->capacity++;
    }
    return Qnil;
}

static VALUE buffer_capture(VALUE self) {
    buffer_t *buffer;

    TypedData_Get_Struct(self, buffer_t, &buffer_data_type, buffer);
    buffer->length = rb_profile_frames(0, buffer->capacity, buffer->profile_frames, buffer->lines);
    return INT2NUM(buffer->length);
}

static VALUE buffer_length(VALUE self) {
    buffer_t *buffer;

    TypedData_Get_Struct(self, buffer_t, &buffer_data_type, buffer);
    return INT2NUM(buffer->length);
}

static VALUE buffer_capacity(VALUE self) {
    buffer_t *buffer;

    TypedData_Get_Struct(self, buffer_t, &buffer_data_type, buffer);
    return INT2NUM(buffer->capacity);
}

static VALUE buffer_aref(VALUE self, VALUE ruby_index) {
    buffer_t *buffer;
    int index = NUM2INT(ruby_index);

    TypedData_Get_Struct(self, buffer_t, &buffer_data_type, buffer);
    if (index >= 0 && index < buffer->length) {
        return buffer->frames[index];
    }
    return Qnil;
}

static VALUE buffer_each(VALUE self) {
    buffer_t *buffer;

    TypedData_Get_Struct(self, buffer_t, &buffer_data_type, buffer);
    for (int i = 0; i < buffer->length; i++) {
        rb_yield(buffer->frames[i]);
    }
    return Qnil;
}

static VALUE buffer_find(VALUE self) {
    buffer_t *buffer;

    TypedData_Get_Struct(self, buffer_t, &buffer_data_type, buffer);
    for (int i = 0; i < buffer->length; i++) {
        VALUE frame = buffer->frames[i];
        if (RTEST(rb_yield(frame))) {
            return frame;
        }
    }
    return Qnil;
}

VALUE stack_buffer_profile_frame(VALUE buffer_obj, int index) {
    buffer_t *buffer;
    TypedData_Get_Struct(buffer_obj, buffer_t, &buffer_data_type, buffer);
    return buffer->profile_frames[index];
}

int stack_buffer_frame_lineno(VALUE buffer_obj, int index) {
    buffer_t *buffer;
    TypedData_Get_Struct(buffer_obj, buffer_t, &buffer_data_type, buffer);
    return buffer->lines[index];
}

void stack_buffer_define(VALUE mStackFrames) {
    VALUE cBuffer = rb_define_class_under(mStackFrames, "Buffer", rb_cObject);
    rb_define_alloc_func(cBuffer, buffer_allocate);
    rb_define_method(cBuffer, "initialize", buffer_initialize, 1);
    rb_define_method(cBuffer, "length", buffer_length, 0);
    rb_define_method(cBuffer, "capacity", buffer_capacity, 0);
    rb_define_method(cBuffer, "capture", buffer_capture, 0);
    rb_define_method(cBuffer, "[]", buffer_aref, 1);
    rb_define_method(cBuffer, "each", buffer_each, 0);
    rb_define_method(cBuffer, "find", buffer_find, 0);
}
