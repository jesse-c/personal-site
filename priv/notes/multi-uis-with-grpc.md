%{
    title: "Multi-UIs for a daemon and using gRPC to communicate locally from Rust <> Swift",
    tags: ~w(Rust Swift gRPC UI),
    date: "2022-06-24",
}
---
[Jump to sample](#sample)

# Multi-UIs Discovery of a paradigm

While building an extension for [SABnzbd](https://www.raycast.com/jns/sabnzbd) for [Raycast](https://www.raycast.com)[^1], it made me think about a paradigm of multiple UIs. I interact with SABnzbd through its web UI, Raycast, and NZBHydra 2. There may even be another way that I'm not remembering.

The paradigm I thought of from this, and added to my projects list, was something like this:

<img src="/images/notes/simple-map.png" alt="Example: Multi-UIs connected with a daemon" width="600" />

The name that I gave the project/idea was "headless for everything", where headless is the daemon, in that drawing.

Some clients are local, while some are remote, like "Export to website". There are more and more local- and offline-first projects. What if you could export your data to another service? Chuck some local issues/tickets up in Jira and Linear? What if you could E2E as part of that? What if it could realtime, distributed, and collaborative? This is a concept I covered with my undergraduate thesis[^2].

The obvious—and huge—downside is that adding a network in-between brings all the issues that a network inherently has. Maybe [Photon](https://hyperfiddle.notion.site/Demo-Photon-a-full-stack-Clojure-Script-dialect-with-compiler-managed-client-server-data-sync-57aee367c20e45b3b80366d1abe4fbc3) will help us out.

# My first experiment with this paradigm

The Pomodoro technique has occasionally worked well for me. On macOS, I use [Tomato 2](https://tomato2.app)—and highly recommend it! A Pomodoro timer became the first experiment for me.

The first version used sockets and an SQLite DB with the daemon and CLI client written in Rust. I wanted notifications though and with notarising/signing, I didn't like how I would send native macOS notifications.

The second version got rid of SQLite and kept it all in memory to simplify it and used MessagePack.

The third version, which is a work-in-progress, gets rid of sockets and uses gRPC for communication so that I can write a client in Swift. I did look around, and it seemed possible to use sockets with Swift, but again, I didn't like how I would've had to do so.

# Sample: How-to use gRPC to communicate between Rust <> Swift {#sample}

Repository: [https://github.com/jesse-c/grpc-example-rust-swift](https://github.com/jesse-c/grpc-example-rust-swift)

While I plan on writing a step-by-step tutorial, in the desire to get this idea and sample out to the world, I've published the repository.

[^1]: I'm still not decided on Raycast. I would go back to Alfred in a heartbeat if it wasn't so visually dated.

[^2]: [Technology-supported activities through realtime, distributed, and collaborative interfaces](https://github.com/jesse-c/thesis)
