---
title: Cedar, Why?
date: 2000-01-01
description: writing an (elm -> C) compiler
layout: default

---


## December 2, 2016


I am writing a compiler.
For the last few months, I've been thinking through approaches
and talking myself in and out of the project.
This first post is serves as a commitment.
Though I imagine no one will follow this blog, I want to write publicly to a few ends:

 0. Practice communicating Cedar's central ideas
 0. Track progress toward my goal
 0. Embody "open" source


### Cedar's central ideas

Cedar's aims to provide for back-end developers what Elm has provided for me
and hundreds of others on the front-end.
As [the homepage][elm-lang] reads, Elm is "a delightful language for reliable webapps."
By foregoing many "advanced" language features
(mutation, exceptions, inheritance, dynamic dispatch, and more)
Elm has achieved something remarkable:
Elm makes it easy and natural to write well-crafted code on the front-end!
You have to fight the compiler to arrive at spaghetti code,
and if you do find yourself in a mess, the type system makes refactoring a breeze.

Cedar has the same goal, with a different use case.
I enjoy server-side programming, and I am disappointed by the most popular language choices.
Java makes it difficult to write well-crafted code because the responsibility
to check for null and catch runtime exceptions is on the developer.
Other languages on the JVM don't seem to fully escape this weakness
because of the lax approach to interop.
Swift demonstrates promise, but the "multi-paradigm" approach
means that developers must decide to write well-crafted code.
Haskell is often touted as the solution to the above deficiencies,
but it is not easy.
I want a language that makes it easy and natural to write well-crafted code.


### Progress toward the goal

"Blog" is just a truncation of the word [weblog][wikipedia-weblog].
That word reminds me of movies like The Martian,
where the hero records individual moments of progress,
that later amount to a greater story.
Maybe Cedar will be a great story someday.
But if not, writing at least makes me feel like the hero.


### "Open" source

Unfortunately, some "open-source" projects are just a collection of browsable releases.
Open development marks communities that value contribution.
Of course, Cedar is literally nothing right now.
But if this project goes anywhere, I want it to have been open from the start.



<!-- LINKS -->

[elm-lang]: http://elm-lang.org
[wikipedia-weblog]: https://en.wikipedia.org/wiki/Blog
