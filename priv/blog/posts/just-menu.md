%{
    title: "An Emacs menu for Justfiles",
    tags: ~w(magit emacs justfile tip),
    date_created: "2025-05-04",
}
---
Justfiles, as an alternative to Makefiles, have grown a lot in popularity. I use them for projects and at work. A common pattern for things like this (e.g. Cargo, Mix, etc) is to have a transient menu to run commands quickly.

With a little AI assistance, I now have one[^1] that I use daily at work.

It (`just-transient--make-transient`) looks for a Justfile, and if it finds one, it creates a simple list of the recipes, with auto-generated prefixes that don't clash. There's 2 backends, one for a Vterm shell, and the other for Compilation Mode.

Here's an example:

![An auto-generated transient menu of Just recipes](/images/blog/just-transient-menu-example.png)

Feel free to use this approach!

[^1]: [https://github.com/jesse-c/dotfiles/blob/main/home/dot_config/emacs/init.el#L2366-L2486](https://github.com/jesse-c/dotfiles/blob/main/home/dot_config/emacs/init.el#L2366-L2486)
