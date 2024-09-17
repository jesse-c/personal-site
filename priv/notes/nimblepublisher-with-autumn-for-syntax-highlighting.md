%{
    title: "Using Autumn with NimblePublisher for synax highlighting",
    tags: ~w(elixir nimblepublisher),
    date: "2024-05-22",
}
---
For this website, I currently use NimblePublisher[^1] for the content management. By default, it uses Earmark for Markdown and different Makeup packages for syntax highlighting.

Having tried to write a Makeup parser[^2], and being a big fan of Tree-sitter, I was happy to hear about Autumn[^3] and MDex [^5]. Autumn uses a Rust crate under-the-hood, through Rustler, for Tree-sitter-based syntax highlighting!

It took a few minutes to customise my different content types with NimblePublisher to use a custom HTML converter module[^4].

[^1]: [NimblePublisher](https://github.com/dashbitco/nimble_publisher)

[^2]: [Makeup parser for Swift](@/notes/makeup_parser_for_Swift.md)

[^3]: [Autumn](https://github.com/leandrocp/autumn)

[^4]: [Custom HTML Converter](https://github.com/dashbitco/nimble_publisher?tab=readme-ov-file#custom-html-converter)

[^5]: [MDex](https://github.com/leandrocp/mdex)
