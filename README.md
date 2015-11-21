# Atomic rtags

A package for the [atom](atom.io) editor that provides excellent C++ code
navigation functionality using [rtags](https://github.com/Andersbakken/rtags).

## Usage

First, download and install rtags. This may be a somewhat laborious process, but
should be pretty straightforward. Then, use it to index your project: should be
as simple as `ninja -t commands | rc -c -` if you're using ninja, and `rc -J .`
if you're using CMake.

Next, install this package through Atom, and configure the locations of your
`rc` and `rdm` executables (the defaults most likely won't work). Open your
code, and hit <kbd>alt</kbd>+<kbd>,</kbd> with the cursor positioned at the
symbol you want to look up.

## Troubleshooting

Check that `rc -f <filename>:<line>:<column>` works for some symbol you want to
look up. Try starting `rdm` from the command-line and inspect the error, if the
package wasn't able to start it.

## Why not YCM?

[YouCompleteMe](https://github.com/Valloric/YouCompleteMe) is a popular choice
for the task; however, rtags beats ycm in practice: ycm is slow, confusing, hard
to configure, and complains about not being able to look up definitions often.
