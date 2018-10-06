---
title: elm-beam
layout: default
---

# ⚠️ WIP ⚠️

I've been exploring the idea of an Elm compiler that produces assembly for the Erlang Virtual Machine.
You can find the code for [this project on GitHub](https://github.com/hkgumbs/elm-beam).
This essay documents some interesting parts of the project.


### Background

According to [the website](https://elm-lang.org/), Elm is a "a delightful language for reliable webapps."
I am a huge fan of the language and its goals, and I encourage you to give it a try.
Elm helped me enjoy writing front-end code again, and many in the community share that experience.
The Elm ecosystem is focused on the front-end webapp domain.
This domain focus is much of what makes Elm delightful —
the tooling, documentation, and community largely coalesce around this goal.

This experience with Elm produces a particular effect in many folks.
I've heard it called the X-is-great-so-we-should-use-X-everywhere effect.
A large part of our small community is excited by the idea of "Elm on the server",
though that phrase likely means different things for different people.
I enjoy how the Elm author responds to this idea in [the roadmap document](https://github.com/elm/projects/blob/master/roadmap.md#can-i-use-elm-on-servers):

> Many folks tell me “Elm should compile to X” where X is a thing they like.
> Here are people suggesting [Go](https://twitter.com/zvozin/status/847860742787223553), [Lua](https://groups.google.com/d/msg/elm-dev/Mi9j3nVD5NE/11akZGmNAgAJ) and [Erlang](https://groups.google.com/d/msg/elm-dev/Mi9j3nVD5NE/Pf1GXS2QAgAJ)...
> But why not go through OCaml or C# or Java or Scala or F# or Haskell or ES6 or C++ or Rust or node.js?

> **The hard part of supporting a domain is not the compiler. It is making a good ecosystem.**
> Python is nice for scientific computing because of things like NumPy and SciPy, not because of whatever backend.
> Elm is nice for front-end because of the ecosystem, like the HTML library and The Elm Architecture, not the particulars of code generation.
> **Just putting a typed functional language in a domain does not mean it will be fun and productive in practice!**

> ... Writing a compiler backend is like 5% of what it takes to make a project like this worthwhile.

I echo 100% of this idea.
The project discussed here **is not** "Elm on the server".
Nor is it a suggested direction for the Elm team.
Instead, it's a fun exploration in compilers and code generation that I'm excited to share with other folks.
Perhaps the work here will help someone interested in building a delightful language for reliable web servers.


### Project overview

```
$ tree
.
├── elm-compiler
│   └── # GIT SUBMODULE OF 0.18 ELM COMPILER
└── src
    ├── ElmBeam
    │   └── # BRIDGE BETWEEN SUBMODULE AND src/
    ├── Generate
    │   └── # CODEGEN MODULES
    └── Main.hs
```

`elm-beam` is a Haskell project with 2 major dependencies:
the 0.18 Elm compiler and a BEAM codegen library I wrote called [codec-beam].
Interop with the Elm compiler is a bit untraditional.
The Cabal file points _both_ to files in this project and files in the git submodule.
[Building the project](https://github.com/hkgumbs/elm-beam#setup-guide)
results in an executable that takes a `.elm` file and produces a file called `elm.beam`.


### The Erlang Virtual Machine

In many ways, Elm matches the semantics of Erlang and Elixir.
These languages all feature immutable data structures, pattern matching, and lambda functions.
However, the similarities run even deeper — to the implementation of the Elm runtime itself.
Here is a quote from [the documentation of the Process module](https://package.elm-lang.org/packages/elm/core/latest/Process):

> Right now, this library is pretty sparse.
> For example, there is no public API for processes to communicate with each other.
> This is a really important ability, but it is also something that is extraordinarily easy to get wrong!

> I think the trend will be towards an Erlang style of concurrency,
> where every process has an “event queue” that anyone can send messages to. 

Internally, the Elm runtime is built upon the idea of processes and messages.
It seems this implementation is explicitly inspired by Erlang's design.
Elm programmers will recognize this design from their use of ports,
[Elm's means of JavaScript interop](https://guide.elm-lang.org/interop/ports.html).
In order to communicate between JavaScript and your Elm application, you send messages!
Much like inter-process communication in Erlang.

```
  SENDING A MESSAGE

app.ports.fromJS.send(x)  // Elm ↔ JavaScript
App_pid ! X               %% Erlang ↔ Erlang


  RECEIVING A MESSAGE

app.ports.toJS.subscribe(x => f(x))  // Elm ↔ JavaScript
receive X -> f(X) end                %% Erlang ↔ Erlang
```

`elm-beam` builds upon these similarities.
The compiled Elm application results in a `.beam` module that defines an
[OTP gen_server](http://erlang.org/doc/design_principles/gen_server_concepts.html).
Starting a `gen_server` and communicating with it uses Erlang functions from the standard library.
You can see these functions in action in the following demo:

<script src="https://asciinema.org/a/9XYQWQNlAvqMzTL54JLZSySXA.js" id="asciicast-9XYQWQNlAvqMzTL54JLZSySXA" async></script>


### `gen_server` design implications

TODO

 - gen_server as the unit of isolation
 - Actor model made explicit


### Generating BEAM

TODO


### Thoughts on the future

TODO


[codec-beam]: https://github.com/hkgumbs/codec-beam
