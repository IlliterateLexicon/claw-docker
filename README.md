# claw-docker
like the scratch image but copys libs and bins from your build step and compresses them making tiny images

## this is an example showing how to run neovim using claw in docker compose

```
services:
  neovim-claw:  { build: { context: .,       target: claw, additional_contexts: { copy: service:neovim-build }}}
  neovim-build: { build: { context: example, target: build }}
```

## this is the dockerfile refrenceing claw
```
# build stage (pre claw compression, copy things to /copy)
from alpine as build 
run apk add --no-cache neovim

# write the init script (or mount as a volume)
workdir /copy
run echo "nvim -v" > ./init.sh

# copy neovim to the bin
workdir /copy/bin
workdir /usr/bin
run cp ./nvim /copy/bin

# copy necicary libs for neovim (discover using trial and error, objump, ldd, etc)
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

# for example neovim needs these lua objects aswell
workdir /copy/usr/lib/lua/5.1
workdir /usr/lib/lua/5.1
run cp \
	./lpeg.so \
	/copy/usr/lib/lua/5.1

# bin stage (post claw, things are uncompressed from /copy)
from claw as bin
workdir /
```

## run like this
```docker compose up --build```
