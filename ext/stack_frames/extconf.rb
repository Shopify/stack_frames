require 'mkmf'
$CFLAGS << ' -Wall -Werror -Wextra -Wno-unused-parameter -Wno-missing-field-initializers'
create_makefile("stack_frames/stack_frames")
