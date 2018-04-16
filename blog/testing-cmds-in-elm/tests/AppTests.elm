module AppTests exposing (..)

import Expect
import Test exposing (..)
import Testable.App exposing (Msg(..), init, update)
import Testable.Effects exposing (Effects)


defaults : Effects msg (Maybe a)
defaults =
    { http = \_ -> Nothing
    , none = Nothing
    }


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


expectEffects : List (a -> Expect.Expectation) -> Maybe a -> Expect.Expectation
expectEffects fs =
    Maybe.withDefault (Expect.fail "no effects") << Maybe.map (Expect.all fs)
