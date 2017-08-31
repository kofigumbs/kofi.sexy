---
layout: post
title: How JSON decoding works in Elm—Part 3
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


In the [last post][], we learned how to compose `Decoder`s
in order to model JSON values that contain other JSON values.
So far, however, we've only been able to extract built-in types,
like `String`, `Int`, and `List`.
Now we'll make our module a bit friendlier by letting users build custom types
and providing great error messages as they do so!


### A map from A to B

Let's begin by looking at the type signature for `Json.Decode.map`:

```elm
map : (a -> b) -> Decoder a -> Decoder b
map _ _ =
    Debug.crash "TODO"

-- TRY IT OUT: https://ellie-app.com/43yWY6hWbVfa1/1
```

The `map` function allows us to transform the type of our decoder
by providing a function _from_ the current type, _to_ the target type.
Suppose we have a `UserId` type with a constructor that takes an `Int`.
We can create a `Decoder UserId` like so:

```elm
type UserId =
    UserId Int

userIdDecoder : Decoder UserId
userIdDecoder =
    map UserId int

-- TRY IT OUT: https://ellie-app.com/43yWY6hWbVfa1/2
```

Hey, that looks like a good opportunity for a test case!

```elm
test "decodes a user id" <|
    \_ ->
        decodeValue userIdDecoder (Jnumber 123)
            |> Expect.equal (Ok (UserId 123))

map : (a -> b) -> Decoder a -> Decoder b
map transform (Decoder parameterAttempt) =
    let
        attemptToDecode value =
            Debug.crash "TODO"
    in
        Decoder attemptToDecode

-- TRY IT OUT: https://ellie-app.com/43yWY6hWbVfa1/4
```

Let's pause and observe the variables to which we have access.

 - `value` has type `Value`
 - `parameterAttempt` has type `Value -> Result String a`
 - `transform` has type `a -> b`
 - `attemptToDecode` _must_ have type `Value -> Result String b`

The breakdown above should make it clear how we can use the
available functions to fill in the body of `attemptToDecode`.
Our `value` must first be decoded with `parameterAttempt`,
so that we can have access to the `Result String a`.
Once we have it, we can just use our `transform` function to create the correct type.
As it happens, the `Result` type has its own `map` function,
which is perfect for this situation.

```elm
map : (a -> b) -> Decoder a -> Decoder b
map transform (Decoder parameterAttempt) =
    let
        attemptToDecode value =
            parameterAttempt value
                |> Result.map transform
    in
        Decoder attemptToDecode

-- TRY IT OUT: https://ellie-app.com/43yWY6hWbVfa1/5
```


### Decode this `andThen` decode that

Imagine that we want to validate the `UserId` type introduced above
since negative id's do not make much sense in our app.
It would be nice if we could model this invariant in our `Decoder`,
so that it is not even possible to create a bad `UserId`.
Well, that's exactly what `succeed`, `fail`, and `andThen` let us do.


```elm
succeed : a -> Decoder a
succeed _ =
    Debug.crash "TODO"

fail : String -> Decoder a
fail _ =
    Debug.crash "TODO"

andThen : (a -> Decoder b) -> Decoder a -> Decoder b
andThen _ _ =
    Debug.crash "TODO"

userIdDecoder : Decoder UserId
userIdDecoder =
    let
        ensurePositive n =
            if n > 0 then
                succeed (UserId n)
            else
                fail "Need a positive number"
    in
        int |> andThen ensurePositive

-- TRY IT OUT: https://ellie-app.com/43yWY6hWbVfa1/6
```

These functions let us decode with much more precision
because we can now filter according to our own rules.
Quite exciting!

```elm
test "fails to decode a negative number" <|
    \_ ->
        decodeValue userIdDecoder (Jnumber -5)
            |> Expect.equal (Err "Need a positive number")
        
succeed : a -> Decoder a
succeed a =
    Decoder (\_ -> Ok a)

fail : String -> Decoder a
fail reason =
    Decoder (\_ -> Err reason)

andThen : (a -> Decoder b) -> Decoder a -> Decoder b
andThen transform (Decoder parameterAttempt) =
    let
        attemptToDecode value =
            parameterAttempt value
                |> Result.map (\param -> Debug.crash "What here?!")
    in
        Decoder attemptToDecode

-- TRY IT OUT: https://ellie-app.com/43yWY6hWbVfa1/7
```

`succeed` and `fail` allow us to create `Decoder`s with predefined behavior,
regardless of the `Value` used as input.
`andThen` is a little tricker though.
The type signature _almost_ looks like that of `map`,
and we can get pretty far copying that general structure.
Let's pause again to reflect on the variables in scope:

 - `param` has type `a`
 - `transform` has type `a -> Decoder b`
 - `attemptToDecode` _must_ have type `Value -> Result String b`

The types tell us that we can use `transform param` to get a `Decoder b`,
but we actually need to return a `Result String b`.
That means we need a function that takes a `Decoder b` and returns a `Result String b`...
We have that function already: [`decodeValue`][]!
We'll also take advantage of [`Result.andThen`][], to flatten out our `Result`.

```elm
andThen : (a -> Decoder b) -> Decoder a -> Decoder b
andThen transform (Decoder parameterAttempt) =
    let
        attemptToDecode value =
            parameterAttempt value
                |> Result.andThen (\param -> decodeValue (transform param) value)
    in
        Decoder attemptToDecode

-- TRY IT OUT: https://ellie-app.com/43yWY6hWbVfa1/8
```


### Helpful errors: Elm's secret sauce

Thus far we've glossed over one major feature of Elm's `Json.Decode` library:
great error messaging.
For instance `decodeString (field "a" (list string)) """{"a": ["x", 123]}"""`
will fail with a helpful message: `"Expecting a String at _.a[1] but instead got: 123"`.
This error is quite specific
because Elm has pinpointed exactly where the decoding went wrong.
Our module, in contrast, would return `"not a string"`.
Let's take a stab at better error messages, by keeping track of an error context.

```elm
type Decoder =
    Decoder (String -> Value -> Result String a)

decodeValue : Decoder a -> Value -> Result String a
decodeValue =
    runDecoder "_"

runDecoder : String -> Decoder a -> Value -> Result String a
runDecoder context (Decoder attemptToDecode) value =
    attemptToDecode context value

-- TRY IT OUT: https://ellie-app.com/43yWY6hWbVfa1/9
```

This change to the `Decoder` type forces a number of changes inside of our module.
All of our `attemptToDecode` helpers, must now take an additional `String` parameter,
which I am calling `context`.
With those mechanical changes out of the way,
we can write a test for the error messaging we want to see.

```elm
test "better error messaging" <|
    \_ ->
        Jobject (Dict.singleton "a" (Jarray [Jstring "x", Jnumber 123]))
            |> decodeValue (field "a" (list string))
            |> Expect.equal (Err "Expecting a String at _.a[1] but instead got: 123")

-- TRY IT OUT: https://ellie-app.com/43yWY6hWbVfa1/10
```

We'll start by adjusting the implementation of `string`
to take advantage of the new `context` parameter.

```elm
string : Decoder String
string =
    let
        attemptToDecode context value =
            case value of
                Jstring foundIt ->
                    Ok foundIt
                _ ->
                    Err <|
                        "Expecting a String at "
                            ++ context
                            ++ " but instead got: "
                            ++ givenString value
    in
        Decoder attemptToDecode

givenString : Value -> String
givenString value =
    case value of
        Jnumber foundIt ->
            toString foundIt
        _ ->
            Debug.crash "TODO"

-- TRY IT OUT: https://ellie-app.com/43yWY6hWbVfa1/11
```

Running the tests at this point reveals that we are very close:

    Err "Expecting a String at _.a[1] but instead got: 123"
    ╷
    │ Expect.equal
    ╵
    Err "Expecting a String at TODO but instead got: 123"

Now we need to build up the `context` inside the decoders that we wrote in the
[last post][].

```elm
field : String -> Decoder a -> Decoder a
field key (Decoder parameterAttempt) =
    let
        -- The new part: building error message context
        withDot context value =
            parameterAttempt (context ++ "." ++ key) value

        decodeKey context object =
            Dict.get key object
                |> Result.fromMaybe "TODO"
                |> Result.andThen (withDot context)

        attemptToDecode context value =
            case value of
                Jobject foundIt ->
                    decodeKey context foundIt
                _ ->
                    Err "TODO" -- we can use `givenString` here
    in
        Decoder attemptToDecode

list : Decoder a -> Decoder (List a)
list (Decoder parameterAttempt) =
    let
        -- The new part: building error message context
        withBrackets context i value =
            parameterAttempt (context ++ "[" ++ toString i ++ "]") value

        collectResults next all =
            Result.map2 (::) next all

        attemptToDecode context value =
            case value of
                Jarray foundIt ->
                    List.indexedMap (withBrackets context) foundIt
                        |> List.foldr collectResults (Ok [])
                _ ->
                    Err "TODO" -- we can use `givenString` here
    in
        Decoder attemptToDecode

-- TRY IT OUT: https://ellie-app.com/43yWY6hWbVfa1/12
```

And we're passing!
Of course, there is much left `TODO`,
but we've now developed a structure to easily build up these error contexts.
The next step is to determine the error message that would be most helpful
in each of those cases.
This sort of work is required for a good API,
but it does not fit within the scope of this blog series.


------


I've mentioned "the immediate convenience of [`JSON.parse`][]" in all three posts,
but we have not taken the opportunity to reflect on that claim.
In JavaScript and Ruby, a successful call to `JSON.parse`
only means that the input was valid JSON.
Once you have the data, **you still need code to ensure it is well-formed for _your_ app.**

Unfortunately, this step is often skipped —
we assume that valid JSON means that the data is in the shape our app needs.
This has some unfortunate consequences:

 - When our assumption is incorrect, the fail site is quite far from the `JSON.parse`
 - We force our internal structure to fit that of the API

Elm's approach alleviates both of these concerns.
The assumptions in JavaScript and Ruby are now codified as _rules_ in our Elm decoders
And as we saw above, you will even get a nice error message!
Second, our application data models not need depend on the shape of our JSON.
If a remote field name changes, we just update the string passed into `field`,
so there's no no need to search our entire app.

JSON decoding is just an example of what I like about Elm:
its thoughtful design enoucourages clean code.
Hopefully these posts helped you develop both
an intuition for the _how_ behind `Json.Decode` and an appreciation for the _why_.


[`JSON.parse`]: https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/JSON/parse
[`Json.Decode`]: http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Json-Decode
[`decodeValue`]: http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Json-Decode#decodeValue
[last post]: {{site.baseurl}}/kofi-gumbs/2017/07/17/elm-json-decoding-data-structures.html
[`Result.andThen`]: http://package.elm-lang.org/packages/elm-lang/core/5.1.1/Result#andThen
