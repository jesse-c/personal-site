%{
    title: "Magit plugin for git-spice (for stacked pull requests)",
    tags: ~w(emacs emacs-lisp feat magit side-project stacked-pull-requests git),
    date_created: "2025-08-16",
}
---
git-spice[^2] is a CLI tool for stacked pull requests. It has forge support for GitHub, so far.

Since Emacs is my primary editor, with Magit in it, I wanted to see how quickly I could add initial support for git-spice.

There's an open issue[^1], but for now I wanted to test it out. I patched in the most basic JSON output.

Here's what it looks like in Magit so far:

![Magit section](/images/blog/magit-section-git-spice-knowledge-graph.png)
![ResNet-50 architecture](/images/blog/magit-section-git-spice-cpr-sdk.png)

[^1]: [log: --json output git-spice#780](https://github.com/abhinav/git-spice/issues/780#issuecomment-3192803506)
[^2]: [git-spice](https://abhinav.github.io/git-spice/)
