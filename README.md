# Neomake Autolint

Neomake Autolint leverages [Neomake]'s ability to asynchronously run linters on
a file. It augments that functionality with the ability to run file level
linters as you type so you get the most immediate feedback. This requires your
version of [Vim] or [Neovim] to support job control, otherwise the plugin will
be disabled. Thanks goes out to the team of Neomake for making a great plugin!

## Requirements

Since Neomake Autolint is built upon [Neomake] the requirements for Neomake
Autolint are the same as [Neomake]'s requirements for async support. While it
may be possible to use this plugin without async support by setting
*g:neomake_autolint_enabled* manually it is not something that will be actively
supported.

For more details see [Neomake's requirements](https://github.com/neomake/neomake#requirements).

## Installation

### [Neobundle](https://github.com/Shougo/neobundle.vim) / [Vundle](https://github.com/gmarik/Vundle.vim) / [vim-plug](https://github.com/junegunn/vim-plug)

```vim
NeoBundle 'neomake/neomake'
Plugin 'neomake/neomake'

NeoBundle 'dojoteef/neomake-autolint'
Plugin 'dojoteef/neomake-autolint'

Plug 'neomake/neomake' | Plug 'dojoteef/neomake-autolint'
```

### [pathogen](https://github.com/tpope/vim-pathogen)

```
git clone https://github.com/neomake/neomake ~/.vim/bundle/neomake
git clone https://github.com/dojoteef/neomake-autolint ~/.vim/bundle/neomake-autolint
```

## Frequently Asked Questions (FAQ)

### Neomake Autolint is not working.

There are a small number of issues that could cause Neomake Autolint to be
disabled. 

First verify that [Neomake] is installed. Neomake Autolint depends on Neomake
so if it is not installed Neomake Autolint will not work.

Check if your version of vim supports jobs and timers. You can verify this by
typing: `:echo has('nvim') || has('job') && has('timers')`

If you do not have job-control and still desire to run Neomake Autolint you
can override the default behavior by setting `g:neomake_autolint_enabled` to
1.

Another issue that could cause Neomake Autolint to be disabled is a missing
cache directory. In order to run a linter over the currently edited file it
needs to be saved to disk. Neomake Autolint saves those temporary files in the
directory as specified in `g:neomake_autolint_cachedir`. Please verify the
cache directory exists.

### Can the sign column always be displayed?

See `g:neomake_autolint_sign_column_always` in the plugin documentation.

## Plugin Documentation

For more detailed documentation, especially regarding configuration, please
refer to the [plugin's help](https://github.com/dojoteef/neomake-autolint/tree/master/doc/neomake-autolint.txt)
(`:h neomake-autolint.txt`).
