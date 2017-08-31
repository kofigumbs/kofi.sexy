---
layout: post
title: How JSON decoding works in Elm—Part 1
authors: ["kofi-gumbs"]
tags: ["Coding"]
---

Elm approaches JSON much differently than languages like JavaScript and Ruby.
Elm's built-in functions don't offer the immediate convenience of [`JSON.parse`][].
You'll find built-in `Decoder`s for the basic types, like `String` and `Int`,
but there is no single function that says "just grab whatever is in this HTTP response."
Instead, the standard library takes a modular approach,
providing a few building blocks that can be arbitrarily composed.
This design makes Elm's JSON decoding (or parsing) flexible and precise.
Over the next few posts, we will discover this ourselves
by implementing a simplified version of the [`Json.Decode`][] module.


### The "Value" type

Our goal is to implement `decodeValue` and all the functions that build `Decoder`s.
We'll begin by copying the main types in `Json.Decode`'s public interface.
I'm getting these straight from the package.elm-lang.org documentation.

```elm
type Decoder a =
    Decoder

type Value =
    Value

decodeValue : Decoder a -> Value -> Result String a
decodeValue _ _ =
    -- For more on `Result` and error handling in Elm,
    -- check out the guides:
    --   https://guide.elm-lang.org/error_handling/result.html
    Debug.crash "fix me"

-- TRY IT OUT: https://ellie-app.com/3xpx2GTvbpLa1/0
```

These types look suspicious, since they each only have one constructor,
but with this skeleton in place we can begin filling in the details.
A look at the standard library internals reveals that
`Json.Decode` uses native modules for special runtime support.
We, however, are going to create a pure Elm version,
which means we'll need to create a `Value` type that can represent any of the possible JSON types.

```elm
type Value
    = Jnull
    | Jnumber Float
    | Jstring String
    | Jboolean Bool
    -- we'll do object and array later

-- TRY IT OUT: https://ellie-app.com/3xpx2GTvbpLa1/4
```

It's not yet clear what a `Decoder` should be, so let's write our first test.


### Give me a string

```elm
test "successfully decode a string" <|
    \_ ->
        Jstring "hi"
            |> decodeValue string
            |> Expect.equal (Ok "hi")

-- TRY IT OUT: https://ellie-app.com/3xpx2GTvbpLa1/5
```

This test fails to compile since `string` does not exist.
Let's copy that signature over as well.

```elm
string : Decoder String
string =
    Decoder

-- TRY IT OUT: https://ellie-app.com/3xpx2GTvbpLa1/6
```

Ok! We're compiling again,
but our test causes a runtime exception because of the call to `Debug.crash`.
We need to fill in the body for `decodeValue`, but first,
consider what computation needs to occur.
In order to extract `"hi"` from the `Value`,
we'll need to pattern-match within a `case` expression.
So the next question is, where should that pattern-matching live?
Inside `decodeValue` or `string`?
Well, we want `decodeValue` to be useful for _any type_ of `Decoder`,
so we cannot hard-code any `String`-specific stuff.
We'll do this pattern-matching inside of `string`,
so that we can keep `decodeValue` nice and generic.
So let's define `Decoder` as a function that takes a `Value`
and tries to extract some `a` out of it.

```elm
type alias Decoder a =
    Value -> Result String a

decodeValue : Decoder a -> Value -> Result String a
decodeValue decoder value =
    decoder value

string : Decoder String
string value =
    case value of
        Jstring foundIt ->
            Ok foundIt
        _ ->
            Debug.crash "fix me"

-- TRY IT OUT: https://ellie-app.com/3xpx2GTvbpLa1/7
```

Alright, we have our first passing test!


### Simple error messaging

The call to `Debug.crash` tells me that there's still work to do.
Let's write a test for the unhappy path.

```elm
test "fail to decode a string" <|
    \_ ->
        Jnumber 0.0
            |> decodeValue string
            |> Expect.err

-- TRY IT OUT: https://ellie-app.com/3xpx2GTvbpLa1/8
```

That forces us to fix our crash-prone `string` `Decoder`.

```elm
string : Decoder String
string value =
    case value of
        Jstring foundIt ->
            Ok foundIt
        _ ->
            Err "not a string"

-- TRY IT OUT: https://ellie-app.com/3xpx2GTvbpLa1/9
```

This error handling is very rudimentary, but Elm values good error messaging!
We'll come back to our error messages once we've built some more complex decoders.


### Enforcing boundaries

Every good API needs thoughtful border control.
Library authors think carefully about how their code should be used
in order to prevent problematic scenarios.
Since `type alias Decoder` leaks details about _how_ our module works,
it invites misuse and confusion.
The [package website explains][] why this is the case:

> Exported or not, client code can construct and inspect [type aliased values]
> without your library, which is also bad when it comes time to extend it.
> Instead, use a union type where the type is exported but the tags are not,
> known as an opaque type.
> It's not hidden since you can see that it's there,
> but you can't see into it, hence it's opaque.

Promoting `Decoder` from `type alias` to `type` can simplify our API externally
_and_ insulate our users from internal change.
Keeping the `Decoder` constructor unexposed turns the recommended usage into the only usage.
Let's re-imagine our module with an opaque `type Decoder`.

```elm
module Jdecode exposing
    ( Decoder
    , decodeValue
    , string
    )

type Decoder a
    = Decoder (Value -> Result String a)

string : Decoder String
string =
    let
        attemptToDecode value =
            case value of
                Jstring foundIt ->
                    Ok foundIt

                _ ->
                    Err "not a string"
    in
        Decoder attemptToDecode

decodeValue : Decoder a -> Value -> Result String a
decodeValue (Decoder attemptToDecode) value =
    attemptToDecode value

-- TRY IT OUT: https://ellie-app.com/3xpx2GTvbpLa1/10
```

We wind up with a little more code in our module to wrap and unwrap the `Decoder` type,
but remember, we're thinking about the users of this library now.
This change also makes our module look more like the original `Json.Decode`,
which is a good sign.


---


I won't walk through the implementations for `int`, `float`, and `bool`,
because they are very similar to `string`.
If you want to check your answers, check out [my complete example on Ellie][].

Primitive decoders are simple because each one is very focused.
As we work through the other functions in this module,
you will likely be surprised how simple each individual piece really is.
I hope you'll stay tuned for Part 2:
exploring [data structures][] with recursive `Decoder`s.


[`JSON.parse`]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/parse
[`Json.Decode`]: http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Json-Decode
[package website explains]: http://package.elm-lang.org/help/design-guidelines#keep-tags-and-record-constructors-secret
[my complete example on Ellie]: https://ellie-app.com/3xp9sbKTHB2a1/4
[data structures]: http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Json-Decode#data-structures
