require 'mkmf'
$CFLAGS << ' -Wall '
$CFLAGS << ' -Werror ' if ENV['STACK_FRAMES_DEV']
create_makefile("stack_frames/stack_frames")
