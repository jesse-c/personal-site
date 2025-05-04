%{
    title: "Add conventional commits, with scopes, to your Magit commit messages",
    tags: ~w(magit emacs conventional-commits tip),
    date_created: "2025-05-04",
}
---
Good practices generally need minimal barriers to implement and barriers to overcome. One of those is conventional commits. I've used them to narrow down changes in Git logs, to add clarity to a commit's intent, to encourage splitting up changes into distinct changes (i.e. don't fix something and add a new feature together, break them up), and so on.

Even if you really like them, you still want to help yourself out. For me, that was adding `y`/`n` question to Magit for when I start a commit, for if I want to use conventional commits or not.

The flow, assuming a `y` answer is:

1. Choose the commit kind (i.e. `fix`) from an auto-completing list[^1]
2. Optionally choose from scopes I've already used (i.e. `blog`), from an auto-completing list[^2]
3. Finish writing the commit, from the starting point I now have of `fix(blog): ...`

Feel free to use this approach!

[^1]: [https://github.com/jesse-c/dotfiles/blob/main/home/dot_config/emacs/init.el#L328-L343](https://github.com/jesse-c/dotfiles/blob/main/home/dot_config/emacs/init.el#L328-L343)
[^2]: [https://github.com/jesse-c/dotfiles/blob/main/home/dot_config/emacs/init.el#L280-L327](https://github.com/jesse-c/dotfiles/blob/main/home/dot_config/emacs/init.el#L280-L327)
