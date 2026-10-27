# claw-docker
like the scratch image but copys libs and bins from your build step and compresses them making tiny images

## this is an example showing how to run neovim using claw

```
services:
  # first: neovim-build neovim-build runs outputs to copy
  #  next: neovim-claw compresses the files in copy
  #  last: files are decompressed and ran from the claw image
  neovim:       { build: { context: example, target: bin,  additional_contexts: { claw: service:neovim-claw  }}}
  neovim-claw:  { build: { context: .,       target: claw, additional_contexts: { copy: service:neovim-build }}}
  neovim-build: { build: { context: example, target: build }}
```

