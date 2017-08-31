---
layout: post
title: How JSON decoding works in Elm—Part 2
authors: ["kofi-gumbs"]
tags: ["Coding"]
---

> Elm approaches JSON much differently than languages like JavaScript and Ruby.
> Elm's built-in functions don't offer the immediate convenience of [`JSON.parse`][].
> You'll find built-in `Decoder`s for the basic types, like `String` and `Int`,
> but there is no single function that says "just grab whatever is in this HTTP response."
> Instead, the standard library takes a modular approach,
> providing a few building blocks that can be arbitrarily composed.
> This design makes Elm's JSON decoding (or parsing) flexible and precise.
> Over the next few posts, we will discover this ourselves
> by implementing a simplified version of the [`Json.Decode`][] module.


In the [last post][], we discussed the major types in play—`Value` and `Decoder`—and
discovered how primitive decoders work (they are just functions!).
Here we'll go beyond primitives and look at decoders for objects and arrays.
Spoiler: they are also just functions!


### Putting the 'O' in JSON

Let's begin by looking at the type signature for the `field` decoder.
Again, I'll get this straight from [the documentation][]:


```elm
field : String -> Decoder a -> Decoder a
field _ _ =
    Debug.crash "fix me"

-- TRY IT OUT: https://ellie-app.com/3LjrbwNR5T3a1/0
```

The `field` decoder "zooms into" an object according to some named field,
then tries to decode the associated value.
Speaking of "value", we still need to extend our `Value` type in order to
represent JSON objects.

```elm
type Value
    = Jnull
    | Jnumber Float
    | Jstring String
    | Jboolean Bool
    | Jobject (Dict String Value)

-- TRY IT OUT: https://ellie-app.com/3LjrbwNR5T3a1/1
```

Now that we have our typed skeletons, we are able to write a test that compiles.

```elm
test "decodes a field" <|
    \_ ->
        Jobject (Dict.singleton "num" (Jnumber 5))
            |> decodeValue (field "num" int)
            |> Expect.equal (Ok 5)

-- TRY IT OUT: https://ellie-app.com/3LjrbwNR5T3a1/2
```

Ok, let's try the general pattern that arose in the previous post.

```elm
field : String -> Decoder a -> Decoder a
field key (Decoder parameterAttempt) =
    let
        attemptToDecode value =
            case value of
                Jobject foundIt ->
                    Debug.crash "fix me"
                _ ->
                    Err "not an object"
    in
        Decoder attemptToDecode

-- TRY IT OUT: https://ellie-app.com/3LjrbwNR5T3a1/3
```

This gets us close, but this time around, we can't just return `Ok foundIt`.
Instead, we have to do two things:

 - Find the key-value pair in our `Dict`
 - If we find a matching pair, run `parameterAttempt` on the value

We can implement these steps like so:

```elm
field : String -> Decoder a -> Decoder a
field key (Decoder parameterAttempt) =
    let
        decodeKey object =
            case Dict.get key object of
                Just value ->
                    parameterAttempt value
                Nothing ->
                    Err "couldn't find key"

        attemptToDecode value =
            case value of
                Jobject foundIt ->
                    decodeKey foundIt
                _ ->
                    Err "not an object"
    in
        Decoder attemptToDecode

-- TRY IT OUT: https://ellie-app.com/3LjrbwNR5T3a1/4
```

Great, we've decoded our first data structure!
Of course, `{"num":5}` is a boring payload, so let's spice it up.
What if we put an object _inside_ another object...
and then put that object inside an object...
and then... I think you get the idea.

```elm
test "decodes a very nested field" <|
    \_ ->
        let
            json =
                Jobject <| Dict.singleton "very" <|
                    Jobject <| Dict.singleton "very" <|
                        Jobject <| Dict.singleton "nested" (Jboolean True)

            decoder =
                field "very" <|
                    field "very" <|
                        field "nested" bool
        in
            Expect.equal (Ok True) (decodeValue decoder json)

-- TRY IT OUT: https://ellie-app.com/3LjrbwNR5T3a1/5
```

It turns out that this test passes, without any modification to our `field` function.
The `field` function actually provides everything we need to decode arbitrarily nested JSON objects.
This test demonstrates just that.


### Repeating decoders

Let's add the final constructor to our `Value` type.
I'll also copy the type for the next function that we'll tackle.

```elm
type Value
    = Jnull
    | Jnumber Float
    | Jstring String
    | Jboolean Bool
    | Jobject (Dict String Value)
    | Jarray (List Value)

list : Decoder a -> Decoder (List a)
list _ =
    Debug.crash "fix me"

-- TRY IT OUT: https://ellie-app.com/3LjrbwNR5T3a1/7
```

In English, `list` takes a decoder for _any_ type
and returns a decoder for a `List` of that type.
The returned decoder knows how to execute the parameter decoder a bunch of times
if it comes across a JSON array value.
Here's a test that illustrates the semantics:

```elm
test "decodes a list of strings" <|
    \_ ->
        Jarray [Jstring "oh", Jstring "hai"]
            |> decodeValue (list string)
            |> Expect.equal (Ok ["oh", "hai"])

-- TRY IT OUT: https://ellie-app.com/3LjrbwNR5T3a1/8
```

If we continue with the same approach we took for `field`...

```elm
list : Decoder a -> Decoder (List a)
list (Decoder parameterAttempt) =
    let
        attemptToDecode value =
            case value of
                Jarray foundIt ->
                    Debug.crash "...what now?"
                _ ->
                    Err "not an array"
    in
        Decoder attemptToDecode

-- TRY IT OUT: https://ellie-app.com/3LjrbwNR5T3a1/9
```

...it's not immediately obvious what to do in the `Jarray` branch.
We _do_ know that we need to run our decoder for every item in the list,
and that we need to accumulate the `Result` somehow.
Whenever I need a function in that shape, I look to the `List` module's [folding functions][].
Let's use `List.foldr`, which builds the resulting list up from the right.
This means we'll be prepending at each step.

```elm
list : Decoder a -> Decoder (List a)
list (Decoder parameterAttempt) =
    let
        initialValue : Result String (List a)
        initialValue =
            Debug.crash "...how do I start?"

        collectResults : Value -> Result String (List a) -> Result String (List a)
        collectResults value resultSoFar =
            Debug.crash "...what now?"

        attemptToDecode value =
            case value of
                Jarray foundIt ->
                    List.foldr collectResults initialValue foundIt
                _ ->
                    Err "not an array"
    in
        Decoder attemptToDecode

-- TRY IT OUT: https://ellie-app.com/3LjrbwNR5T3a1/10
```

This compiles, which tells us our types are aligned.
Let's think about `initialValue` next:
what do we need to return, when `foundIt` is empty?
Well, decoding an empty list always succeeds with an empty list,
so we can just insert `Ok []` there.

On to `collectResults`.
Now that we have an individual list item, `value`, we can call `parameterAttempt`.
This will leave us with a `Result` that we must combine with `resultSoFar`,
There are four possible scenarios, but since we only have one test, we'll skip some for now.

```elm
list : Decoder a -> Decoder (List a)
list (Decoder parameterAttempt) =
    let
        initialValue =
            Ok []

        collectResults value resultSoFar =
            case ( parameterAttempt value, resultSoFar ) of
                ( Ok nextDecoded, Ok decodedSoFar ) ->
                    Ok (nextDecoded :: decodedSoFar)
                _ ->
                    Err "part of array failed"

        attemptToDecode value =
            case value of
                Jarray foundIt ->
                    List.foldr collectResults initialValue foundIt
                _ ->
                    Err "not an array"
    in
        Decoder attemptToDecode

-- TRY IT OUT: https://ellie-app.com/3LjrbwNR5T3a1/11
```

And we're passing.

The [data structures][] section has other functions that I won't cover here,
but they all have the same general shape:
"Give me a decoder of some type,
and I will give you a decoder that 'boxes' that type in some way."
In the interest of writing a blog post and not a book,
I'll leave those as an exercise for the reader.


### A methodical approach

Let's reflect on the approach we used to create these `Decoder`s.
For instance, as we were thinking about `list`,
we did three things to make the problem more manageable:

 - We used `Debug.crash` when we did not know what to do
 - We thought about the general problem and decided `List.foldr` was a decent fit
 - We refactored `attemptToDecode` by creating `collectResults` and `initialValue`,
   but we still had a `Debug.crash` at first

If you ran the tests before and after that transformation,
you would have seen no difference—we had a crashing function both before and after.
However, we did make the problem _much_ easier to solve.
Before, we needed a function of type `List Value -> Result`,
but afterwards, we only had to think of a function of type `Value -> Result -> Result`.
We made the problem easier by peeling back one layer (the `List` in our case).

I use this pattern often when working in typed languages like Elm.
Here's an attempt at a generalized version of the same approach:

 - `Debug.crash` when the solution is not immediately obvious
 - Identify the kind of function we need from the type signatures
 - Refactor and fill in the "easy" parameters that represent the base case
 - If it's still unclear, repeat

Elm's type checker ensures that my pieces still match up,
which allows me to focus on solving smaller problems one at a time
while remaining confident in the larger relationships between my functions.


---


Similarly to last time,
there are some improvements that can be made to the module described above.
If you want to check your answers, check out [my complete example on Ellie][].

In the last post, we saw that primitive `Decoder`s are focused and simple.
Though the complexity certainly increases in the `Decoder`s discussed in this post,
we developed a rhythm that allowed us to tackle the difficulty in small chunks.
Delegating some of the "heavy lifting" to the type system
can make things feel simple.
In the next and final post, we will implement the [mapping functions][],
which allow us to build up JSON `Decoder`s for custom types.


[`JSON.parse`]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/parse
[`Json.Decode`]: http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Json-Decode
[last post]: {{site.baseurl}}/kofi-gumbs/2017/06/28/elm-json-decoding-types.html
[the documentation]: http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Json-Decode#field
[folding functions]: http://package.elm-lang.org/packages/elm-lang/core/latest/List#folding
[data structures]: http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Json-Decode#data-structures
[my complete example on Ellie]: https://ellie-app.com/3HQ5pyVNh9fa1/0
[mapping functions]: http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Json-Decode#mapping
