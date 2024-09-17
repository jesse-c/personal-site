%{
    title: "Raycast extension for Himalaya released",
    tags: ~w(macos email raycast himalaya),
    date: "2023-04-29",
}
---
Previously[^1][^2], I wrote about a paradigm where you had daemon which had multi-UIs that interacted with it. For some time I had wanted to quickly be able to act on emails as they come in. Someone is working on a Raycast extension that uses AppleScript to interact with Mail.app[^3]. Whilst it's tractable, it was taking some time&mdash;and then I remembered Himalaya[^4]!

After testing it out, I was happy with it and set out to try and build a Raycast extension[^5] around it. I'm happy to further announce that it's available for us! I've already had several new minor versions since the original release.

Along with this, I got into a discussion with @soywood[^6] over email as I had sponsored him on GitHub. It turns out, the paradigm[^1] I wrote about, and his own project[^6] had converged on the same approach! Hilariously, we had both been working on Pomodoro timers.

Up next? A Raycast extension for Comodoro[^8].

[^1]: [Multi-UIs for a daemon and using gRPC to communicate locally from Rust <> Swift](@/notes/multi-uis-with-grpc.md)

[^2]: [Technology-supported activities through realtime, distributed, and collaborative interfaces](https://github.com/jesse-c/thesis)

[^3]: [[New Extension] Apple Mail #4080](https://github.com/raycast/extensions/pull/4080)

[^4]: [Himalaya (CLI)](https://github.com/soywod/himalaya)

[^5]: [Himalaya (Raycast)](https://www.raycast.com/jns/himalaya)

[^6]: [@soywood](https://github.com/soywod)

[^7]: [Pimalaya](https://pimalaya.org)

[^8]: [Comodoro](https://pimalaya.org/comodoro/)
