%{
    title: "Counting pages in sections from other sections in Zola",
    tags: ~w(zola),
    date: "2022-10-11",
}
---
For the design of this website (as of 2022-10-11), I wanted to include the number of pages in a section—e.g., in the menu. I found a post on the Zola forum[^1] where I learnt about the `get_section` and a section's `pages` variable. Then in the Tera documentation[^2], I found the `length` function.

Between the 2 of these, I'm able to display the pages count.

**Example**

```
{% set notes = get_section(path="notes/_index.md") -%}
{{ notes.pages | length }}
```

**Update:** Notes have been renamed to blog (and posts).

[^1]: [https://zola.discourse.group/t/section-vs-page/522/8 ↗](https://zola.discourse.group/t/section-vs-page/522/8)

[^2]: [https://tera.netlify.app/docs/#length ↗](https://tera.netlify.app/docs/#length)
