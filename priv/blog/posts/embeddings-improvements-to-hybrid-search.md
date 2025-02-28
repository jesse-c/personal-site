%{
    title: "Embeddings improvements to hybrid search for Notes.app",
    tags: ~w(side-project machine-learning vespa macos huggingface),
    date_created: "2024-09-13",
}
---
To reduce use of embeddings outside of Vespa itself, I've removed it from the data transformation pipeline [^2] and the querying CLI [^1].

[^1]: [jesse-c/notes-app-hybrid-search#1](https://github.com/jesse-c/notes-app-hybrid-search/pull/1)

[^2]: [jesse-c/notes-app-hybrid-search#2](https://github.com/jesse-c/notes-app-hybrid-search/pull/2)
