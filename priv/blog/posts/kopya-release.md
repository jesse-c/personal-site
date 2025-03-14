%{
    title: "Alpha release of Kopya",
    tags: ~w(side-project kopya swift macos),
    date_created: "2025-03-14",
}
---
This is the latest, in my ongoing experiments of daemon-first or headless-first[^1][^2][^3] software. This time, it's for my clipboard history, that's turned out to be an invaluable thing to have access oo—much like my shell history. I've created a daemon[^5] and Raycast extension[^6].

Someone has put together a comparison list[^4] of clipboard managers for macOS, that currently has 29 listed! I had been using the built-in Raycast clipboard history, but didn't want to be beholden to that single application.

Using Windsurf, I quickly knocked this together, and it's been working well. Here's a screenshot:

![The extension in Raycast opened](/images/blog/kopya-raycast.png)

Next, I'll make a CLI wrapper for it, though even now it could be used with cURL.

[^1]: [Multi-UIs for a daemon and using gRPC to communicate locally from Rust <> Swift](multi-uis-for-a-daemon-and-using-grpc-to-communicate-locally-from-rust-swift)
[^2]: [Technology-supported activities through realtime, distributed, and collaborative interfaces](https://github.com/jesse-c/thesis)
[^3]: [Raycast extension for Himalaya released](raycast-extension-for-himalaya-released)
[^4]: [Definitive MacApp Comparisons](https://docs.google.com/spreadsheets/d/1JqyglRJXzxaj8OcQw9jHabxFUdsv9iWJXMPXcL7On0M/edit?gid=138343010#gid=138343010)
[^5]: [kopya](https://github.com/jesse-c/kopya)
[^6]: [extensions](https://github.com/jesse-c/extensions/tree/feat/add-kopya/extensions/kopya)
