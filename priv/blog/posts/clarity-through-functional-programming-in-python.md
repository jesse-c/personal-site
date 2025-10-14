%{
    title: "First places to introduce functional programming",
    tags: ~w(functional-programming python),
    date_created: "2025-10-14",
}
---
There was a pattern at work with some fellow engineers, in data engineer roles, where there would be a lot of glue functions in Python. They were all effectively a mapping over a list and doing a transform. People would add unit tests for them too. This doesn't sound like a bad problem, and in a way, it's not.

How it's a problem is that it creates multiple levels of indirection, when understanding the data transformations. I couldn't _immediately_ see what was happening, for what conceptually simple operations of a mapping with a transformation.

With a professional background in functional programming with Elm and then Elixir, and colleagues who were interested, I'd guide refactors. We'd remove those filler functions, simple as that. It improved my colleague's _theory of minds_, since they, and myself, wouldn't think, "Oh yes this goes off to some function and does something".

You can do this too!

Another place are monads, with a result type. We introduced a basic result monad ourselves, and people have found it easier to directly reason about control and code flows, over relying on exceptions. This doesn't mean we don't have any exceptions, of course.
