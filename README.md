# Atomic rtags

A package for the [atom](atom.io) editor that provides excellent C++ code
navigation functionality using [rtags](https://github.com/Andersbakken/rtags).

[![rtags in action](https://media.giphy.com/media/n4Jl6O3mIXyr6/giphy.gif)](http://youtu.be/ShcdCon-OCY)

(Click through for full YouTube video)

## Quickstart

First, download and install rtags. This unfortunately takes a really long time:

```
$ brew install rtags
```

Then, use it to index your project: for CMake-based projects,

```
$ git clone https://github.com/taglib/taglib # replace with your project
$ mkdir taglib-build
$ cd taglib-build
$ cmake -GNinja ../taglib
$ rdm # in another terminal
$ ninja -t commands | rc -c -
```

Next, install `atomic-rtags` through Atom, and check the configuration options.
Open your .cpp file, and hit <kbd>alt</kbd>+<kbd>,</kbd> with the cursor
positioned at the symbol you want to look up.

## Troubleshooting

**Not indexed**: Index your project by piping the build commands to `rc -c -`.

**(Jumps to incorrect location)**: Open an issue.

**Not found or Indexing in progress**: Inspect the output of `rc -f
<filename>:<line>:<column>` (after starting `rdm`). Some symbols are genuinely
not indexed by rtags though.

**Can't seem to connect to server**: Start `rdm`, or enable `rdmAutoSpawn`,
under configuration options.

**Other error**: Open an issue.

## Why not YCM?

[YouCompleteMe](https://github.com/Valloric/YouCompleteMe) is a popular choice
for the task; however, rtags beats ycm in practice: ycm is slow, confusing, hard
to configure, and complains about not being able to look up definitions often.
