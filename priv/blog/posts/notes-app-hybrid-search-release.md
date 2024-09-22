%{
    title: "Initial release of hybrid search for Notes.app",
    tags: ~w(side-project machine-learning vespa macos),
    date: "2024-09-08",
}
---
* Introduction

One of the ways I use Notes.app is for having a Shortcut that creates a daily note, titled as the current day (e.g. "2024-09-08"), where I use it for journal-esque writings, dropping links to products or articles, project ideas, and _anything_.

Unfortunately, the keyword search in Notes.app isn't always sufficient. I'm sure Apple will add something like this eventually, and for now, I've cobbled something together.

You can try it yourself locally: [https://github.com/jesse-c/notes-app-hybrid-search/](https://github.com/jesse-c/notes-app-hybrid-search/)

* Evaluation

I've tried 2 different models so far, both of which were similar in quality. Along with that, I've manually done searches for queries that in the past, were things I've struggled to find again. It's worked reasonably well. The output needs to be tweaked to have a more useful `snippet`.

* What's next

There's a few things that I'll be adding:

• Evaluate different models

• Host the model in Vespa

• Deploy it, to access it on my phone

• Use sentences over full bodies

• Enrich data, for example by pulling link titles and summaries and creating embeddings from images
