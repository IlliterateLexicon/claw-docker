# claw-docker
like the scratch image but copys libs and bins from your build step and compresses them making tiny images

## this is an example showing how to run neovim using claw in docker compose

```
services:
  # first: neovim-build neovim-build runs outputs to copy
  #  next: neovim-claw compresses the files in copy
  #  last: files are decompressed and ran from the claw image
  neovim:       { build: { context: example, target: bin,  additional_contexts: { claw: service:neovim-claw  }}}
  neovim-claw:  { build: { context: .,       target: claw, additional_contexts: { copy: service:neovim-build }}}
  neovim-build: { build: { context: example, target: build }}
```

## this is the dockerfile refrenceing claw
```
# build stage (pre claw compression, copy things to /copy)
from alpine as build 
run apk add --no-cache neovim

workdir /copy/lib
workdir /usr/lib
run cp \
	./libgcc_s.so.1 \
	./libintl.so.8 \
	./libluajit-5.1.so.2 \
	./libluv.so.1 \
	./libtree-sitter.so.0.26 \
	./libunibilium.so.4 \
	./libutf8proc.so.3 \
	./libuv.so.1 \
	/copy/lib

workdir /copy/usr/lib/lua/5.1
workdir /usr/lib/lua/5.1
run cp \
	./lpeg.so \
	/copy/usr/lib/lua/5.1

workdir /copy/bin
workdir /usr/bin
run cp ./nvim /copy/bin

# bin stage (post claw, things are uncompressed from /copy)
from claw as bin
workdir /
cmd [ "sh", "-c", "./claw.sh; nvim -v" ]
```

