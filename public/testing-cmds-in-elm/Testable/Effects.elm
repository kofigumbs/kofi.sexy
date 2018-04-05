module Testable.Effects exposing (Effects)

import Json.Decode exposing (Decoder)


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
