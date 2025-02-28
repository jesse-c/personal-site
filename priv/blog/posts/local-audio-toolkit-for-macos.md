%{
    title: "New tool: A local audio toolkit for macOS with Whisper and LM Studio",
    tags: ~w(side-project machine-learning audio macos whisper lm-studio),
    date_created: "2024-11-28",
}
---
I've added audio as another interface for regular and useful writing—across daily notes, Git comments, etc. I thought I'd quickly package it up and make it available[^1]. I shared the snippets originally with my colleagues. It uses an MLX version of a Whisper model.

It's helpful because at the moment it takes 3 sources:

1. Record from a microphone
2. Download a YouTube video
3. Provide a path to a local audio file

There's main commands, depending on what I'm doing. Sometimes I want a transcription verbatim. Other times, I want a nice summary. I've added a profile (or, system prompt), to style them specifically depending on my audience. For example, for pull requests.

I've already used this a bunch of times! Try it out yourself[^1].

[^1]: [https://github.com/jesse-c/local-audio-toolkit](https://github.com/jesse-c/local-audio-toolkit)
