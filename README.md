# personal-site

## Local development

Start Redis (required for the shoutbox):

```bash
docker compose up
```

## Docker

To build and run the full production image locally:

```bash
docker compose --profile app up
```

Real secrets (`SECRET_KEY_BASE`, `SENTRY_DSN`, etc.) can be set in your environment or `.env` to override the placeholder defaults.

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

## Vega-Lite charts

Blog posts support inline [Vega-Lite](https://vega.github.io/vega-lite/) charts, rendered client-side via Vega-Embed — interactive by default, with hover tooltips and support for sliders and other controls.

The spec is validated at compile time. Any local data URLs (paths starting with `/`) are checked for existence on disk at compile time too. Data files live in `priv/static/data/`.

### Prerequisites

None — Vega, Vega-Lite, and Vega-Embed (`@vega_lite_version v5`) are loaded lazily from CDN on first render.

### Basic usage

````markdown
```vl
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": { "url": "/data/my-data.csv" },
  "mark": { "type": "line", "point": true },
  "encoding": {
    "x": { "field": "x", "type": "quantitative" },
    "y": { "field": "y", "type": "quantitative" },
    "tooltip": [
      { "field": "x", "type": "quantitative" },
      { "field": "y", "type": "quantitative" }
    ]
  }
}
```
````

### Interactive controls

Bind a parameter to a range slider using Vega-Lite's `params` + `bind`:

````markdown
```vl
{
  "params": [{ "name": "threshold", "value": 65, "bind": { "input": "range", "min": 0, "max": 100, "step": 1, "name": "Threshold" } }],
  ...
}
```
````

### Dark mode

Charts re-render automatically when the page theme changes. Dark mode overrides axis, legend, title, and grid colours to match the site palette.
