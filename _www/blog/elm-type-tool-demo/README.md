---
title: Building a tool that leverages Elm's types
layout: default

---

This is a learn-by-example guide to building tools with Elm's type system.
This guide here accompanies [my Elm in the Spring 2019 talk](/talk/guaranteed-refactors).

In this guide, we'll be implementing a specific tool called `elm-snapshot`.
The specific tool we are building is not very important,
so I'll focus on _extracting and manipulating Elm's types_.
To build `elm-snapshot` locally, clone this repo and run
[`./compile.rb`](https://github.com/hkgumbs/hkgumbs.github.io/blob/elm-snapshot/blog/elm-type-tool-demo/compile.rb).


## Problem Statement

Given some module that defines `someFunction`,
I want to _refactor_ `someFunction` and _verify_ that
I haven't changed behavior.
If my changes do introduce new behavior,
I would like the tool to _inform_ me of the circumstances
under which the behaviour differs from the old implementation.

Traditionally, I achieve this feedback via unit tests.
For this guide, we'll assume that we forgot or neglected to write unit tests for our code.
Is it still possible to reclaim that certainty?
Here is how I would like to use our tool:

```sh
elm-snapshot ./src/ToSentence.elm  # Generates the unique snapshot XYZ
elm-test ./test/Snapshot_XYZ.elm   # Snapshot is just a normal elm-test module

# ... refactor, refactor, refactor ...

elm-test ./test/Snapshot_XYZ.elm   # Snapshot passes if we didn't change behavior!
rm ./test/Snapshot_XYZ.elm         # No need to keep this around
```

Let's take a stab at a concrete answer: what are snapshots?
If we call the original function `f` and the refactored function `g`,
snapshots are tests that verify that:

```
f 1 == g 1 &&
f 2 == g 2 &&
f 3 == g 3 ... and so on and so forth
```

For every valid input to `f`, passing that input into `f` should produce a value
equal to passing the same input into `g`.


## Ruby Setup

We'll be using Ruby to generate our "snapshot modules".
There is nothing particularly interesting about Ruby in this context,
but it is a scripting language that I know well.
Before we get started, we'll make our file executable
and add some standard dependencies.

```ruby
#!/usr/bin/env ruby

require "time"
require "json"
require "pathname"
```

Given the interface I described above,
we'll also bail if we don't get a filepath argument.

```ruby
if ARGV.count != 1
  puts "USAGE: elm-snapshot PATH/TO/YOUR_MODULE.elm"
  exit 1
end
```

This is a great time to start running this file as a sanity check!
After every block of code we add,
the file should still be runnable even though the program isn't complete.


## Extracting Types

When you run `elm make`,
the Elm compiler collects and verifies all the types in your program.
In order to keep subsequent builds fast,
the compiler will write "interface files" that represent the modules in your project.
For instance, after compiling the file `ToSentence.elm`,
you'll find a new file at `elm-stuff/0.19.0/ToSentence.elmi`
which represents all of the types exposed in the `ToSentence` module.

Since we want to make sure that the interface files are up-to-date,
we'll run `elm make` on whatever filepath was passed in to `elm-snapshot`.
If the compiler fails, then we will do the same.

```ruby
puts "=== CRAWLING PROJECT"

path = Pathname.new(ARGV.first)
exit 1 unless system "elm make #{path}"
```

`.elmi` files are encoded using a custom compiler encoding
that typically changes with each new version of Elm.
It's best to think of these files as an implementation detail of the compiler
and not mess with them directly.
We'll inspect these files indirectly, using
[`elmi-to-json`](https://github.com/stoeffel/elm-interface-to-json)—the
same tool that `elm-test` uses to find your unit tests.

First, make sure you have `elmi-to-json` installed (`npm install -g elmi-to-json`).
Then, we can grab the type information as JSON and select the
interface that corresponds to the filepath passed to our program.

```ruby
subject = JSON.parse(`elmi-to-json`).find do |interface|
  path == Pathname.new(interface["modulePath"])
end
```

<details>
<summary>Interface JSON for <a href="https://github.com/hkgumbs/hkgumbs.github.io/blob/elm-snapshot/blog/elm-type-tool-demo/example/src/ToSentence.elm"><code>ToSentence.elm</code></a></summary>
<pre><code class="language-json">
{
  "modulePath" : "src/ToSentence.elm",
  "moduleName" : "ToSentence",
  "interface" : {
     "aliases" : {},
     "types" : {
        "toSentence" : {
           "annotation" : {
              "lambda" : [
                 {
                    "name" : "String",
                    "vars" : [],
                    "moduleName" : {
                       "package" : "elm/core",
                       "module" : "String"
                    },
                    "type" : "Type"
                 },
                 {
                    "type" : "Type",
                    "moduleName" : {
                       "package" : "elm/core",
                       "module" : "String"
                    },
                    "name" : "String",
                    "vars" : []
                 },
                 {
                    "name" : "List",
                    "vars" : [
                       {
                          "moduleName" : {
                             "package" : "elm/core",
                             "module" : "String"
                          },
                          "type" : "Type",
                          "name" : "String",
                          "vars" : []
                       }
                    ],
                    "type" : "Type",
                    "moduleName" : {
                       "module" : "List",
                       "package" : "elm/core"
                    }
                 },
                 {
                    "name" : "String",
                    "vars" : [],
                    "moduleName" : {
                       "module" : "String",
                       "package" : "elm/core"
                    },
                    "type" : "Type"
                 }
              ]
           },
           "vars" : []
        }
     },
     "unions" : {},
     "binops" : {}
  }
}
</code></pre>
</details>


## Building Fuzzers

Consider the snapshot definition we used earlier: `f 1 == g 1 && f 2 == g 2 && ...`.
This snippet suggests that the more numbers we can check,
the more confidence we will have that the two behaviours match.
Whenever we want to simulate a large set of potential values in Elm tests,
we should think of fuzz tests.

> These are called "[fuzz tests](https://en.wikipedia.org/wiki/Fuzz_testing)" because of the randomness.
> You may find them elsewhere called [property-based tests](http://blog.jessitron.com/2013/04/property-based-testing-what-is-it.html),
> [generative tests](http://www.pivotaltracker.com/community/tracker-blog/generative-testing), or
> [QuickCheck-style tests](https://en.wikipedia.org/wiki/QuickCheck).
>
> — [elm-test documentation](https://package.elm-lang.org/packages/elm-explorations/test/latest/Test#fuzz)

If you peek into the [`Fuzz` module documentation](https://package.elm-lang.org/packages/elm-explorations/test/latest/Fuzz),
you'll notice that many of Elm's built-in types have a corresponding function
that returns a `Fuzzer`.
As a first approximation, we'll assume that the types we care about
are all standard library types for which this correspondence is true:
`String`, `Int`, `List String`, `List Int`, etc.

```ruby
fuzzer = -> type do
  if type["moduleName"]["package"] != "elm/core"
    puts "elm-snapshot doesn't handle custom types yet!"
    exit 1
  else
    "(Fuzz."                              +
      type["name"].downcase               +
      " "                                 +
      type["vars"].map(&fuzzer).join(" ") +
      ")"
  end
end
```

This implementation leaves _much_ to be desired—the
above code cannot handle some major parts of Elm's type system.
We could implement these for `elm-snapshot`,
but in the interest of brevity (and laziness) we'll leave them out.
Here are some ideas if you choose to take a stab:
- **Generics:** You can always substitute `()` for generic types.
- **Records:** Since these may hold any number of fields,
  you'll need to use the [`map*`](https://package.elm-lang.org/packages/elm-explorations/test/latest/Fuzz#map)
  functions to compose smaller `Fuzzer`s.
- **Custom Types:** We _cannot_ generate `Fuzzer`s for [Opaque Types](https://package.elm-lang.org/help/design-guidelines#keep-tags-and-record-constructors-secret).
  When present, our tool will need to bail.
  Otherwise, `elmi-to-json` will include the constructors under the `"unions"` key,
  which we can use with [`oneOf`](https://package.elm-lang.org/packages/elm-explorations/test/latest/Fuzz#oneOf)
  to build custom `Fuzzer`s.

Finally, Rubyists may take issue with my arrow style functions here.
Normally, methods are defined with the `def` keyword;
however, this syntax does not let us easily use the global names we've been defining.
Arrow functions let us side-step this restriction and keep this file in literate style.


## Code Generation

Now that we have the function types for our module,
and we know how to generate the right `Fuzzer`s,
we're left with the mundane work of building up a valid `elm-test` module.
To do so, we'll use the following functions,
which each generate a tiny bit of Elm code.

```ruby
make_names = -> args do
  args.each_with_index.map { |_, i| "a#{i}" }
end

make_call = -> (name, args) do
  subject["moduleName"] + "." + name + " " + make_names.(args).join(" ")
end

make_record = -> args do
  "{ " + make_names.(args).map { |x| "#{x} = #{x}" }.join(", ") + " }"
end
```

We'll use a 2-pass approach to generating our snapshot.

1. Generate fuzz tests that exercise our `Fuzzer`s and log the inputs and output
2. Generate unit tests that run the function with the logged inputs and compare against the logged output

We'll use a timestamp to create and track our unique snapshot.
Since the approach above uses 2 test files,
we'll also create a function that does the appropriate `elm-test` setup.

```ruby
timestamp = Time.now.to_time.to_i.to_s

puts "=== GENERATING SNAPSHOT #{timestamp}"

test_module = "Snapshot_#{timestamp}"
test_source = Pathname.pwd.join "tests", test_module + ".elm"

generate_test = -> contents do
  File.write(test_source, <<~ELM.strip)
    module #{test_module} exposing (..)

    import Expect
    import Fuzz
    import Test exposing (..)
    import #{subject["moduleName"]}

    #{contents}
  ELM
end
```

In our first pass, we want to log all of the information required
to call our function _and_ the result of calling the function at this point in time.
For each function in the interface, we'll create a dummy fuzz test,
which exists only to do that logging.
Elm's [`Debug.log`](https://package.elm-lang.org/packages/elm/core/latest/Debug#log)
function does the heavy lifting for us by converting Elm values into their textual representations.
Here's the log format we'll be using:

```
       function name   output
             ↓           ↓
123456789toSentence: 3: ("",{ a1 = "", a2 = "", a3 = [] })
    ↑                ↑                    ↑
timestamp      argument count         arguments
```

Some of this format is forced on us by `Debug.log`,
but it will serve our needs nicely.
In our second pass, we'll parse that format and extract that metadata.
For now, here's how you might generate these "logging fuzz tests":

```ruby
logging_fuzz_test = -> (name, args) do
  <<~ELM
    #{name}_test : Test
    #{name}_test =
      fuzz#{args.count == 1 ? "" : args.count} #{args.map(&fuzzer).join(" ")}
        "#{subject["moduleName"]}.#{name}" <|
          \\#{make_names.(args).join(" ")} ->
            let
              _ = Debug.log "#{timestamp}#{name}: #{args.count}"
                ( #{make_call.(name, args)}
                , #{make_record.(args)}
                )
            in
            Expect.pass
  ELM
end

fuzz_tests = subject["interface"]["types"].map do |name, expression|
  expression["annotation"].keys != [ "lambda" ] \
    ? ""
    : logging_fuzz_test.(name, expression["annotation"]["lambda"][0...-1])
end

generate_test.(fuzz_tests.join("\n"))
```

## Finalizing the Snapshot

The snapshot file we have now, contains a bunch of passing tests.
Running it will have no interesting result... Except for the logs!
If we run our snapshot test module with `elm-test`,
we can use the timestamp to find the logs we just crafted.

```ruby
logs = `elm-test #{test_source} | grep '^#{timestamp}'`.lines.map do |line|
  line.strip[timestamp.length..-1].split(": ", 3)
end
```

That monstrosity of Bash and Ruby splits each relevant log line into three parts:
the function name, the argument count, and the ouput/arguments tuple.
Before we logged the arguments, we packaged them into record.
Here's is the Elm that will let us unpack those in our final snapshot:

```ruby
prelude = <<~ELM
  apply1 f x = f x.a0
  apply2 f x = f x.a0 x.a1
  apply3 f x = f x.a0 x.a1 x.a2
  apply4 f x = f x.a0 x.a1 x.a2 x.a3
  apply5 f x = f x.a0 x.a1 x.a2 x.a3 x.a4
  apply6 f x = f x.a0 x.a1 x.a2 x.a3 x.a4 x.a5
  apply7 f x = f x.a0 x.a1 x.a2 x.a3 x.a4 x.a5 x.a6
  apply8 f x = f x.a0 x.a1 x.a2 x.a3 x.a4 x.a5 x.a6 x.a7
ELM
```

So finally, we have all of the pieces to generate a test module
that fails as we deviate from the behavior of the original function.

```ruby
snapshot = logs.each_with_index.map do |(name, count, output), i|
  <<~ELM
    test_#{name}_#{i} : Test
    test_#{name}_#{i} =
      test "#{name} (\##{i})" <|
        \\_ ->
          let ( result, args ) = #{output} in
          apply#{count} #{subject["moduleName"]}.#{name} args
            |> Expect.equal result
  ELM
end

generate_test.(prelude + snapshot.join("\n"))
```


## Parting Thoughts

I think there are some exciting opportunities for extending `elm-snapshot`.
The "shrinking" story isn't great in our implementation,
so failing tests can be quite unreadable.
I've also found that `Debug.log` does not properly escape some tricky strings,
so the final snapshot may have syntax errors.

Glaring issues aside, `elm-snapshot` has some tremendous upside.
For instance, you could use this kind of tool to freeze
your entire application or library to verify dependency updates.
When I first imagined this tool,
I briefly looked to see if others had experimented in other languages.
The closest prior research I found was
[Ted Kaminski's post on "Ephemeral model-based testing"](https://www.tedinski.com/2018/12/26/model-based-testing.html).
I highly recommend that post and the entirety of Ted's blog.

Hopefully, you've learned a bit about building tooling with and for Elm.
These sorts of personal productivity tools are great playgrounds,
and I'm excited to see the outcome of such experiments in the Elm community.
