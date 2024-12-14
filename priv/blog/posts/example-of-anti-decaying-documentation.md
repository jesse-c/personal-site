%{
    title: "Example of anti-decaying documentation",
    tags: ~w(documentation readme typescript),
    date: "2024-12-06",
}
---
In a previous blog post[^1], I wrote about an idea to avoid documentation decay, like links or installation instructions falling out-of-date. I just had a chance to try it out, on a new project[^2][^3].

The README is generated from a Jinja2 template. So far, it's the tools that are pulled from the actual model context server. Here's the template for that:

```markdown
## Tools
{% for tool in tools %}
### `{{ tool.name }}`
{{ tool.description }}
{% endfor %}
```

The script imports the `TOOLS`, and then passes it to the template rendering function.

```typescript
..

import { TOOLS } from '../src/tools.js';

..

    // Define template variables
    const templateVars = {
      tools: TOOLS.map(tool => ({
        name: tool.name,
        description: tool.description,
        params: Object.keys(tool.inputSchema.properties || {})
      }))
    };

    // Render the template
    const output = env.renderString(template, templateVars);

...
```

Now, it's effectively impossible to be out-of-date or incorrect. As with any generated code, there's the _annoyance_ of having to commit the code, but that is something that's otherwise solved.

[^1]: [Explicitly showing, and checking, documentation decay](explicitly-showing-and-checking-documentation-decay)
[^2]: [https://github.com/jesse-c/linear-context-server-ts](https://github.com/jesse-c/linear-context-server-ts)
[^3]: [First versions of new Linear server for Model Context Protocol](first-versions-of-new-linear-server-for-model-context-protocol)
[^4]: [](https://github.com/jesse-c/personal-site/blob/602728c9e80ea40c94b5fbb4b72c95d63d098f7f/priv/blog/posts/example-of-anti-decaying-documentation.md?plain=1#L9)
