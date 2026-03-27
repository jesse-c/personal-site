# personal-site

## D2 diagrams

Blog posts support inline [D2](https://d2lang.com) diagrams, rendered to SVG at compile time — no JavaScript, no CDN, instant render, with light/dark mode via `prefers-color-scheme`.

### Prerequisites

```bash
brew install d2
```

### Basic usage

````markdown
```d2
x -> y -> z
```
````

### Options

Options are specified in the info string after `d2`:

| Option | Description |
|--------|-------------|
| `border` | 1px border with rounded corners |
| `float=left` | Float diagram left; text flows to the right |
| `float=right` | Float diagram right; text flows to the left |

Options can be combined:

````markdown
```d2 float=right border
x -> y
```
````

### Floated diagrams

When using `float=left` or `float=right`, text following the diagram flows alongside it. To stop the text wrapping, add a clear div after the content that should flow:

```html
<div style="clear: both;"></div>
```

### Collapsible diagrams

Wrap the fenced block in a native HTML `<details>` element. A blank line after `<summary>` is required so that CommonMark processes the D2 block normally:

````markdown
<details>
<summary>Diagram</summary>

```d2 border
x -> y
```

</details>
````

### Themes

Defaults: `@default_light_theme 1` (Neutral Grey) and `@default_dark_theme 201` (Dark Flagship Terrastruct). Scale defaults to `@default_scale_percentage 65`%. Override per-document via `MDExD2.attach/2` options: `:d2_light_theme`, `:d2_dark_theme`, `:d2_scale`.
