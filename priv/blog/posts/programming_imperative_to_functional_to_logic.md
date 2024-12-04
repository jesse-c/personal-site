%{
    title: "Programming: Imperative to Functional to Logic",
    tags: ~w(functional imperative logic programming),
    date: "2024-02-23",
}
---
# How I started programming

This is about my journey with programming languages from imperative to functional to (potentially) logic.

Similar to _most_ people, I got into programming with imperative languages. They were the programming languages (PLs) that I used at my first few jobs—specifically, ColdFusion, PHP, Java, Python, JavaScript, and some others.

Back in high school, I remember our IT teacher briefly introducing us to Prolog, of which I remember very little of, but it's stuck with me as a _neat idea_ ever since.

Then, I worked at a startup that used Go for the API and agents, and then Elm[^2] for the SPA. Why Elm? It was a fortuitous choice by the main frontend engineer. When I joined, there were roughly 4 current software engineers. Why Go? The _usual_ reasons.

Elm, or rather functional programming was fascinating and eye-opening, as trite as that sounds. I won't go into why as others have covered that extensively—though I would like to do so myself one day.

At my next job, there was another fortuitous choice of PLs of Elixir, since the technical co-founder was familiar with it and that it seemed like the right PL (including OTP) for the job.

We've reached a point in my hobby and career that I'm convinced functional programming is overall, better than imperative programming. It's more fun too.

# Okay, so Prolog

With Prolog, and the continuous search for The One True Programming Language. I've found Flix[^1], which may very well be it. It's fairly novel in its design. I'll quote their own answer to their question of "Why Flix?":

> Flix aims to offer a unique combination of features that no other programming language offers, including: algebraic data types and pattern matching (like Haskell, OCaml), extensible records (like Elm), traits (type classes) (like Haskell, Rust), higher-kinded types (like Haskell), typematch (like Scala), type inference (like Haskell, OCaml), structured channel and process-based concurrency (like Go), and compilation to JVM bytecode (like Scala).
>
> Flix also supports several unique features, including: a polymorphic effect system, region-based local mutation, purity reflection, and first-class Datalog constraints.

The Datalog constraints, or declarative logic programming, combined with so many other ideal features was interesting, and it wasn't long until I saw an opportunity to try it out.

# A real world use-case for logic programming/constraint solving

At work, there was a snippet of Go code that was used to find running servers that satisfied having a certain capability (read: framework or runtime) to serve a machine learning model.. It would get/have the list of servers and loop through looking for ones that had the desired capability in its list of capabilities, and return those.

Flix calls the Datalog constraints fixpoints[^3]. The Flix book on them was helpful.

# Implementations by programming approach

I quickly threw something together. It's very simple in that there's a small set of facts (`features()`). It was so simple that I didn't need to implement any explicit rule(s).

```
def features(): #{ IsCapable(String, String) | r } = #{
        IsCapable("MLServer", "TensorFlow").
        IsCapable("MLServer", "Scikit-learn").
        IsCapable("Triton", "PyTorch").
        IsCapable("Triton", "TensorFlow").
    }

def serversWithCapability(c: String): Vector[String] =
    query features() select server from IsCapable(server, c)

def main(): Unit \ IO =
    Vector#{"TensorFlow", "PyTorch", "Transformers"}
    |> Vector.map(serversWithCapability)
    |> println
```

Output:

```
Vector#{Vector#{MLServer, Triton}, Vector#{Triton}, Vector#{}}
```

For comparison, I wrote Elixir and Go versions.

```elixir
defmodule Capabilities do
  @servers [
    %{name: :mlserver, capabilities: [:tensorflow, :scikit_learn]},
    %{name: :triton, capabilities: [:pytorch, :tensorflow]}
  ]

  def servers_with_capabilities(c) do
    @servers
    |> Enum.filter(fn %{capabilities: capabilities} ->
      Enum.member?(capabilities, c)
    end)
    |> Enum.map(& &1.name)
  end
end

[:tensorflow, :pytorch, :transformers]
|> Enum.map(&Capabilities.servers_with_capabilities/1)
|> IO.inspect()
```

Output:

```elixir
[[:mlserver, :triton], [:triton], []]
```

NB: I originally used an LLM with the prompt, "Convert this Elixir code to Go", and received a functionally and syntactically code snippet.

```go
package main

import (
	"fmt"
)

type Server struct {
	Name         string
	Capabilities []string
}

var servers = []Server{
	{Name: "mlserver", Capabilities: []string{"tensorflow", "scikit_learn"}},
	{Name: "triton", Capabilities: []string{"pytorch", "tensorflow"}},
}

func serversWithCapabilities(c string) []string {
	var results []string

	for _, server := range servers {
		for _, capability := range server.Capabilities {
			if capability == c {
				results = append(results, server.Name)
				break
			}
		}
	}

	return results
}

func main() {
	capabilities := []string{"tensorflow", "pytorch", "transformers"}
	results := [][]string{}

	for _, c := range capabilities {
		results = append(results, serversWithCapabilities(c))
	}

	fmt.Println(results)
}
```

Output:

```go
[[mlserver triton] [triton] []]
```

# Side-by-side comparison

An alternative view of the different implementations that highlights the differences, such as length.

[![Each implementation side-by-side in VS Code](/images/blog/flix-elixir-go-servers.png)](/images/blog/flix-elixir-go-servers.png)

# Summary

I've already espoused my view that functional programming is generally preferable to imperative. I view logic programming, in a vague sense, as a higher level of thinking in that there's less I need to _instruct_ the computer to do, and can _declare_ (or, describe) what is to be done, and let it figure it out for me.

One potential barrier to logic programming being adopted is that who wants to learn a whole new programming language that's very specific, as opposed to Rust, Elixir, Clojure, etc that can solve a wide array of problems.

[^1]: [Flix](https://flix.dev)
[^2]: [Elm](https://elm-lang.org)
[^3]: [Fixpoints](https://doc.flix.dev/fixpoints.html)
