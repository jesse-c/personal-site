%{
    title: "Compile Tree-sitter langs for Emacs 29 on an M1",
    tags: ~w(tree-sitter emacs),
    date_created: "2022-12-20",
}
---
Recently I tried Emacs 29[^1] and began slimming down my config[^2]. Following the Tree-sitter starter guide[^3], I couldn't figure out why I wasn't able to start the appropriate mode. I would get errors along the lines of, `Cannot activate tree-sitter, because language definition for ...`.

After double-checking file paths and names, I compared my local build output of the recommend build script[^4] to the provided release—which _did_ work .

The provided release was compiled for `x86_64` and my local build output was for `arm64`. That wasn't wrong, as I _am_ on an M1.

Here's the a simple and lazy to compile for `x64_64` and have it work: `arch -x86_64 ./batch.sh`

[^1]: [jimeh/emacs-builds](https://github.com/jimeh/emacs-builds)

[^2]: [Replacing packages with more "stripped down" packages](https://www.reddit.com/r/emacs/comments/zqdrnz/replacing_packages_with_more_stripped_down/)

[^3]: [Tree-sitter starter guide](https://github.com/emacs-mirror/emacs/blob/master/admin/notes/tree-sitter/starter-guide)

[^4]: [casouri/tree-sitter-module](https://github.com/casouri/tree-sitter-module)
