%{
    title: "From write-up to prototype of static checks for anti-documentation decay",
    tags: ~w(documentation readme research clevis),
    date_created: "2024-12-28",
    date_updated: "2025-06-09",
}
---
In _Explicitly showing, and checking, documentation decay_[^1], I gave a Python snippet for checking some "links" between data in documentation.

After doing some recent changes to keep that project easily usable, I had that snippet sitting locally in my workspace. Recently I used this concept for another real-world project[^3].

The original snippet wasn't far off! The changeset, including the CI workflow is available[^2]. The most interesting part isn't the executing the checks, but how the data is built-up.

## Example

Here's the singular anti-decay link I have so far:

```json
{
  "data-to-search-path": {
    "value": "data/02-plaintext-to-vespa-documents/output/vespa-all.jsonl",
    "a": {
      "link": [
        {
          "type": "path",
          "value": "data/02-plaintext-to-vespa-documents/"
        },
        {
          "type": "toml",
          "file": "data/02-plaintext-to-vespa-documents/config.toml",
          "key": "data.output_file"
        }
      ]
    },
    "b": {
      "link": [
        {
          "type": "span",
          "file": "justfile",
          "key": "5:6-64"
        }
      ]
    }
  }
}
```

Each check has A and B, which could also be source and destination, and the link each part. The idea is that both links would construct the same value.

In this case, it's `"data/02-plaintext-to-vespa-documents/output/vespa-all.jsonl"`. The A link has more than 1 step. It combines all the steps (`|steps| = 2`), to get the complete value. There's different operations, with there being 3 needed for this.

- `path`: A path, and its existence is checked for.
- `toml`: A path to a TOML file, and the accessor key.
- `span`: A path to a file, and a span, which is a line and start and end indices.

This was quick to put together, even from my small base snippet! Imagine a world where all you need to do is define the links, and not implement anything else. You could even expand upon the built-in operations with your own.

[^1]: [Explicitly showing, and checking, documentation decay](explicitly-showing-and-checking-documentation-decay)
[^2]: [notes-app-hybrid-search#3: feat: Add anti-decay checks](https://github.com/jesse-c/notes-app-hybrid-search/pull/3)
[^3]: [Example of anti-decaying documentation](example-of-anti-decaying-documentation)
