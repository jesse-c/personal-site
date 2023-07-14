%{
    title: "Hyper key without Karabiner Elements",
    tags: ~w(Hyper macOS),
    date: "2023-04-13",
}
---
I came across a blog post[^1] about using `hidutil` on macOS. As much as I'm thankful for those who worked on Karabiner Elements, I'm happy to remove a dependency!

This was a simple change to my dotfiles[^2]. I had already used the builtin macOS ability to remap a modifier, which I had done from caps lock to ESC, which I had to remove.

[^1]: [Mac keyboard with hidutil](https://amitp.blogspot.com/2023/04/mac-keyboard-with-hidutil.html)

[^2]: [dotfiles#ee0e45ac0fc68ba055f73011b5a025c992fd5984](https://github.com/jesse-c/dotfiles/commit/ee0e45ac0fc68ba055f73011b5a025c992fd5984)
