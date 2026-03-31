%{
    title: "Statically compile diagrams for blog posts in Markdown",
    tags: ~w(elixir side-project),
    date_created: "2026-03-27",
    date_updated: "2026-03-31",
}
---
Blog posts now support inline diagrams authored in D2[^1].

# Why D2

Like most people, I reached for Mermaid first. I didn't want to add a JavaScript dependency though. D2 is a modern approach to diagrams, and has some nice things like supporting light and dark mode.

# How it works

A custom MDEx[^2] pipeline plugin walks the document AST at compile time, finds every fenced code block tagged `d2`, and replaces it with a `%MDEx.HtmlBlock` containing the rendered SVG. Failures are raised at compile time.

# Usage

A basic diagram:

```d2
x -> y -> z
```

Diagrams support a few options in the info string. A border:

```d2 border
client -> server -> database
```

Float layout, so text flows alongside the diagram:

```d2 float=right border
web -> api -> db
```

The `float=right` option floats the diagram to the right and lets text flow alongside it. Use `float=left` to float it to the left instead. A clear div is needed after the flowing content to stop the wrap.

<div style="clear: both;"></div>

And collapsible diagrams using a native `<details>` element:

<details>
<summary>Diagram</summary>

```d2 border
author -> post -> tag
```

</details>

# Implementation

The plugin is a single file — `lib/personal_site/mdex_d2.ex` — attached in the markdown converter before calling `MDEx.to_html!/1`. The `d2` binary is a prerequisite (installed via `brew install d2` locally, and via the install script in CI)[^4][^5].

You can see it in use in an existing post[^3].

# Using codefence renderers

I learnt about MDExes new codefence renderer[^6] via the Thinking Elixier podcast[^7]. It was a simple refactor[^8], to switch over to it.

[^1]: [D2](https://d2lang.com)
[^2]: [MDEx](https://github.com/leandrocp/mdex)
[^3]: [First shell command prediction model](first-shell-command-prediction-model)
[^4]: [feat(blog): Add statically compiled diagrams](https://github.com/jesse-c/personal-site/commit/091745b)
[^5]: [build: Use Docker over Railpack](https://github.com/jesse-c/personal-site/commit/4dad1bf)
[^6]: [v0.11.6](https://github.com/leandrocp/mdex/blob/main/CHANGELOG.md#0116---2026-02-24)
[^7]: [Thinking Elixir #295: Is Your Type System Leaking?](https://podcast.thinkingelixir.com/295)
[^8]: [refactor: Use MDExes new codefence renderers](https://github.com/jesse-c/personal-site/commit/5ecd0eb6165e72bb61a71ee11d2085b9c530c7e4)
