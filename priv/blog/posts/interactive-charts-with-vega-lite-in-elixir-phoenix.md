%{
    title: "Interactive charts with Vega-Lite in Elixir Phoenix",
    tags: ~w(blog vega-lite elixir phoenix side-project mdex markdown),
    date_created: "2026-04-01",
}
---
After adding diagrams[^1], I wished I had nicer charts[^2].

Interactive charts are rendered from `vl` fenced code blocks. The spec is validated at compile time, so any local data URLs are checked for existence too. The data lives in `priv/static/data/`.

## Examples

Here's some examples.

### Loss curves

A multi-series line chart using Vega-Lite's `fold` transform to pivot `train_loss` and `val_loss` from wide to long format.

```vl
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": { "url": "/data/vega-example/training.csv" },
  "transform": [
    {
      "fold": ["train_loss", "val_loss"],
      "as": ["split", "loss"]
    }
  ],
  "mark": { "type": "line", "point": true },
  "encoding": {
    "x": { "field": "epoch", "type": "quantitative", "title": "Epoch" },
    "y": { "field": "loss", "type": "quantitative", "title": "Loss" },
    "color": { "field": "split", "type": "nominal", "title": "Split" },
    "tooltip": [
      { "field": "epoch", "type": "quantitative" },
      { "field": "split", "type": "nominal" },
      { "field": "loss", "type": "quantitative", "format": ".4f" }
    ]
  }
}
```

<details>
<summary>Source</summary>

````
```vl
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": { "url": "/data/vega-example/training.csv" },
  "transform": [
    {
      "fold": ["train_loss", "val_loss"],
      "as": ["split", "loss"]
    }
  ],
  "mark": { "type": "line", "point": true },
  "encoding": {
    "x": { "field": "epoch", "type": "quantitative", "title": "Epoch" },
    "y": { "field": "loss", "type": "quantitative", "title": "Loss" },
    "color": { "field": "split", "type": "nominal", "title": "Split" },
    "tooltip": [
      { "field": "epoch", "type": "quantitative" },
      { "field": "split", "type": "nominal" },
      { "field": "loss", "type": "quantitative", "format": ".4f" }
    ]
  }
}
```
````

</details>

### Accuracy

Same pattern for accuracy, with an interactive slider to set a reference threshold line.

```vl
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": { "url": "/data/vega-example/training.csv" },
  "params": [
    {
      "name": "threshold",
      "value": 65,
      "bind": {
        "input": "range",
        "min": 40,
        "max": 80,
        "step": 1,
        "name": "Accuracy threshold (%)"
      }
    }
  ],
  "layer": [
    {
      "transform": [
        { "fold": ["train_acc", "val_acc"], "as": ["split", "accuracy"] }
      ],
      "mark": { "type": "line", "point": true },
      "encoding": {
        "x": { "field": "epoch", "type": "quantitative", "title": "Epoch" },
        "y": { "field": "accuracy", "type": "quantitative", "title": "Accuracy (%)" },
        "color": { "field": "split", "type": "nominal", "title": "Split" },
        "tooltip": [
          { "field": "epoch", "type": "quantitative" },
          { "field": "split", "type": "nominal" },
          { "field": "accuracy", "type": "quantitative", "format": ".2f" }
        ]
      }
    },
    {
      "mark": { "type": "rule", "strokeDash": [4, 4], "color": "gray" },
      "encoding": {
        "y": { "datum": { "expr": "threshold" }, "type": "quantitative" }
      }
    }
  ],
  "config": { "view": { "padding": { "top": 10 } } }
}
```

<details>
<summary>Source</summary>

````
```vl
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": { "url": "/data/vega-example/training.csv" },
  "params": [
    {
      "name": "threshold",
      "value": 65,
      "bind": {
        "input": "range",
        "min": 40,
        "max": 80,
        "step": 1,
        "name": "Accuracy threshold (%)"
      }
    }
  ],
  "layer": [
    {
      "transform": [
        { "fold": ["train_acc", "val_acc"], "as": ["split", "accuracy"] }
      ],
      "mark": { "type": "line", "point": true },
      "encoding": {
        "x": { "field": "epoch", "type": "quantitative", "title": "Epoch" },
        "y": { "field": "accuracy", "type": "quantitative", "title": "Accuracy (%)" },
        "color": { "field": "split", "type": "nominal", "title": "Split" },
        "tooltip": [
          { "field": "epoch", "type": "quantitative" },
          { "field": "split", "type": "nominal" },
          { "field": "accuracy", "type": "quantitative", "format": ".2f" }
        ]
      }
    },
    {
      "mark": { "type": "rule", "strokeDash": [4, 4], "color": "gray" },
      "encoding": {
        "y": { "datum": { "expr": "threshold" }, "type": "quantitative" }
      }
    }
  ],
  "config": { "view": { "padding": { "top": 10 } } }
}
```
````

</details>

### Learning rate schedule

The `ReduceLROnPlateau` scheduler halving the learning rate is visible as discrete steps.

```vl
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": { "url": "/data/vega-example/training.csv" },
  "mark": { "type": "line", "point": true, "color": "steelblue" },
  "encoding": {
    "x": { "field": "epoch", "type": "quantitative", "title": "Epoch" },
    "y": {
      "field": "lr",
      "type": "quantitative",
      "title": "Learning rate",
      "scale": { "type": "log" }
    },
    "tooltip": [
      { "field": "epoch", "type": "quantitative" },
      { "field": "lr", "type": "quantitative", "format": ".6f" }
    ]
  }
}
```

<details>
<summary>Source</summary>

````
```vl
{
  "$schema": "https://vega.github.io/schema/vega-lite/v5.json",
  "data": { "url": "/data/vega-example/training.csv" },
  "mark": { "type": "line", "point": true, "color": "steelblue" },
  "encoding": {
    "x": { "field": "epoch", "type": "quantitative", "title": "Epoch" },
    "y": {
      "field": "lr",
      "type": "quantitative",
      "title": "Learning rate",
      "scale": { "type": "log" }
    },
    "tooltip": [
      { "field": "epoch", "type": "quantitative" },
      { "field": "lr", "type": "quantitative", "format": ".6f" }
    ]
  }
}
```
````

</details>

[^1]: [Statically compile diagrams for blog posts in Markdown](statically-compile-diagrams-for-blog-posts-in-markdown)
[^2]: It would've been nice for [First shell command prediction model](first-shell-command-prediction-model)
