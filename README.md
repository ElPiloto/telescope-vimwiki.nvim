# telescope-vimwiki.nvim

Look for your vimwiki pages using telescope!

### Requirements:

- neovim (>= 0.5.0)
- vimwiki

### Installation

```require'telescope'.load_extension'vimwiki'```


### Usage

List vimwiki pages for default (0th) vimwiki:

```:Telescope vimwiki```

Specify a different vimwiki via `index` or `i` for short

```:Telescope vimwiki index=1```
or
```:Telescope vimwiki i=1```



#### TODO

- [X] Add way of configuring which vimwiki you want, currently just defaults to 0-th wiki.
