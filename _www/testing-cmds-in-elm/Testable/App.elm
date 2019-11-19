module Testable.App exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Testable.Effects exposing (Effects)


-- MODEL


type alias Model =
    { topic : String
    , gifUrl : String
    }


init : Effects Msg cmd -> String -> ( Model, cmd )
init effects topic =
    ( Model topic "waiting.gif"
    , getRandomGif effects topic
    )



-- UPDATE


type Msg
    = MorePlease
    | NewGif (Maybe String)


update : Effects Msg cmd -> Msg -> Model -> ( Model, cmd )
update effects msg model =
    case msg of
        MorePlease ->
            ( model, getRandomGif effects model.topic )

        NewGif (Just newUrl) ->
            ( Model model.topic newUrl, effects.none )

        NewGif Nothing ->
            ( model, effects.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ h2 [] [ text model.topic ]
        , button [ onClick MorePlease ] [ text "More Please!" ]
        , br [] []
        , img [ src model.gifUrl ] []
        ]



-- HTTP


getRandomGif : Effects Msg cmd -> String -> cmd
getRandomGif effects topic =
    let
        url =
            "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic
    in
    effects.http
        { method = "GET"
        , url = url
        , decoder = decodeNewGif
        , onError = NewGif Nothing
        }


decodeNewGif : Decode.Decoder Msg
decodeNewGif =
    Decode.at [ "data", "image_url" ] Decode.string
        |> Decode.map (NewGif << Just)
