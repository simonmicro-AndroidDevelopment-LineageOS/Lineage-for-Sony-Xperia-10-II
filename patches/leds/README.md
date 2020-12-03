Enable notification LED color support (need to patch it directly as the rro overlay is currently broken on LOS 17.1)
This patch also may disables the blinking support, as the kernel driver is currently broken and renders blinking led
colors useless as they always end up white or rainbow... -> https://github.com/sonyxperiadev/bug_tracker/issues/577
