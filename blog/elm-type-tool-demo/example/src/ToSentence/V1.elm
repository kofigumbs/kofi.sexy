module ToSentence.V1 exposing (toSentence)


toSentence : String -> String -> List String -> String
toSentence emptyString joinString list =
    case List.length list of
        0 ->
            emptyString

        1 ->
            toSentenceImplementation emptyString "" list

        2 ->
            toSentenceImplementation emptyString (" " ++ joinString ++ " ") list

        _ ->
            toSentenceImplementation emptyString (", " ++ joinString ++ " ") list


toSentenceImplementation : String -> String -> List String -> String
toSentenceImplementation emptyString andString list =
    let
        head =
            List.head list |> Maybe.withDefault ""

        tail =
            List.tail list |> Maybe.withDefault []
    in
    case List.length list of
        0 ->
            emptyString

        1 ->
            head

        2 ->
            head ++ andString ++ toSentenceImplementation emptyString andString tail

        _ ->
            head ++ ", " ++ toSentenceImplementation emptyString andString tail
