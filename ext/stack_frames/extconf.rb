require 'mkmf'
$CFLAGS << ' -Wall -Wextra -Wno-unused-parameter -Wno-missing-field-initializers -fvisibility=hidden'
$CFLAGS << ' -Werror' if ENV['STACK_FRAMES_DEV']
create_makefile("stack_frames/stack_frames")
