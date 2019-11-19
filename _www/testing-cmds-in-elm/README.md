---
title: Testing Cmd's in Elm
description: A brief post + example about dependency injection
categories: ['blog']

---

This problem frequently appears in [#testing on Elm Slack](https://elmlang.slackarchive.io/testing),
and I've been curious about what a "dependency injection" API might look like.
Dependency injection, in general, is quite simple.
If you have something that you want to test (or just isolate),
then instead of working with that thing directly,
pass it as an argument wherever you need it!
This repo is an example of what it might look like to use Dependency injection to make `Cmd`s easy to test!


### Where to start

[Original.elm](https://github.com/hkgumbs/kofi.sexy/tree/master/_blogs/testing-cmds-in-elm/Original.elm)
is taken directly from the [Elm Architecture Tutorial](https://github.com/evancz/elm-architecture-tutorial).
We'll be looking at this application the whole time, so it's worth understanding what it does.
When you click the button, the app requests a random GIF from giphy.com.
Also, when you start the app, it makes an HTTP request right away.
Simple enough.


### So how do I test the HTTP request?

First let's state the problem:

1. In order to send a HTTP request in Elm, you **must** package it is a `Cmd`
2. Once you package something as a `Cmd`, you have no ability to **inspect** it

Together these mean that the Elm architecture guides you towards a solution that is tricky to unit test.
Let's see how dependency injection can help us.
**Instead of creating `Cmd`s inside of our application,
let's pass the `Cmd`s that we intend to use as an argument**:

```elm
-- Testable/Effects.elm

type alias Effects msg wrapper =
    { http :
        { method : String
        , url : String
        , decoder : Decoder msg
        , onError : msg
        }
        -> wrapper
    , none : wrapper
    }
```

You can read the type alias like as `Effects`,
which are generic over `msg` (just like `Cmd`!),
can _produce_ some `wrapper`, which is _not necessarily a `Cmd`_.
First, we'll take a look at `main`, where the `wrapper` _is_ a `Cmd`.
Then, we'll check out the tests, where we exchange `Cmd` for something easier to inspect.

```elm
-- Testable/Main.elm

effects : Effects msg (Cmd msg)
effects =
    { http =
        \{ method, url, decoder, onError } ->
            Http.request
                { method = method
                , url = url
                , headers = []
                , body = Http.emptyBody
                , expect = Http.expectJson decoder
                , timeout = Nothing
                , withCredentials = False
                }
                |> Http.send (Result.withDefault onError)
    , none = Cmd.none
    }


main =
    Html.program
        { init = Testable.App.init effects "cats"
        , view = Testable.App.view
        , update = Testable.App.update effects
        , subscriptions = \_ -> Sub.none
        }
```

You can see that our `init` and `update` functions are a bit different now:
they take `Effects` as the first parameter.
This restricts the kinds of stuff they can return—it must be created with one of the fields in the record!
So even though we've introduced some indirection, we have maintained type safety.
Let's take a peek at where `Effects` is ultimately used, just to make sure:

```elm
getRandomGif : Effects Msg cmd -> String -> cmd
getRandomGif effects topic =
    effects.http
        { method = "GET"
        , url = "... some long url ..." ++ topic
        , decoder = decodeNewGif
        , onError = NewGif Nothing
        }
```

We did this all in the name of "testability", but I've yet to show you a test!
Well, fear no longer, and rejoice in the fruits of your labor:

```elm
-- Overwrite this in each test where you want to "capture" effects!
-- You can use `Just` to isolate the effect that you care about,
-- although in our example, that will only be HTTP.
-- In more complicated apps, you could even use a `List` instead of a `Maybe`
defaults : Effects msg (Maybe a)
defaults =
    { http = \_ -> Nothing , none = Nothing }


suite : Test
suite =
    describe "`Cmd`s that can be tested"
        [ test "asks for GIFs, right off the bat" <|
            \_ ->
                init { defaults | http = Just } "dogs"
                    |> Tuple.second
                    |> expectEffects
                        [ .method >> Expect.equal "GET"
                        , .url >> String.endsWith "tag=dogs" >> Expect.true "url tag"
                        ]
        , test "does not queue `Cmd`s when GIF is received" <|
            \_ ->
                init defaults "robots"
                    |> Tuple.first
                    |> update { defaults | http = Just } (NewGif (Just "a-robot"))
                    |> Tuple.second
                    |> Expect.equal Nothing
        , test "MorePlease is more `Cmd`s" <|
            \_ ->
                init defaults "pigeons"
                    |> Tuple.first
                    |> update { defaults | http = Just } MorePlease
                    |> Tuple.second
                    |> expectEffects
                        [ .url >> String.endsWith "tag=pigeons" >> Expect.true "url tag"
                        ]
        ]
```


### Perhaps a better question!

Is the test and resulting code more pleasant to maintain?
In our quest for testability, we actually gave up quite a few niceties of Elm.
First, we've removed the explicit dependency on the well-documented `http` library.
Of course, this is the essence of dependency injection, so it may seem strange to list it as a loss.
The real concern is that we actually lose the ability to use _any_ Elm standard library directly within our app.
Any time that we want to implement an effect, we must add it to our `Effects` record to maintain testability!
All of the work that library authors put into designing pleasant and composable APIs is lost in the name of testability.

The second note is that we've increased the complexity of all of our type signatures.
This means any errors that arise will be trickier to debug.
Compounded with the fact that the `Effects` module is unique to your application,
this will certainly hurt the beginner-friendliness of your code.

---

I do not know whether these downsides negate the utility of this approach.
Stuff like this can be tricky to illustrate with a small code base,
since simple code often doesn't benefit at all from test coverage.
Regardless, it's encouraging to know that a testable solution is entirely possible,
should the need arise before other solutions do!


### Credits

Thanks to [Byron](https://github.com/BWoodfork), whose idea this was originally,
and [Justin](https://github.com/7hoenix/) who helped me prototype the first version.
