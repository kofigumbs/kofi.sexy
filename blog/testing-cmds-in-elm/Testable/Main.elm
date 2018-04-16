module Main exposing (..)

import Html
import Http
import Testable.App
import Testable.Effects exposing (Effects)


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


main : Program Never Testable.App.Model Testable.App.Msg
main =
    Html.program
        { init = Testable.App.init effects "cats"
        , view = Testable.App.view
        , update = Testable.App.update effects
        , subscriptions = \_ -> Sub.none
        }
