module ToSentence.V2 exposing (toSentence)


toSentence : String -> String -> List String -> String
toSentence emptyString joinString list =
    case list of
        [] ->
            emptyString

        [ onlyOne ] ->
            onlyOne

        [ first, last ] ->
            first ++ " " ++ joinString ++ " " ++ last

        _ ->
            longSentence joinString list


longSentence : String -> List String -> String
longSentence joinString list =
    let
        nMinusOne =
            List.length list - 1

        start =
            List.take nMinusOne list

        end =
            List.drop nMinusOne list
    in
    String.join ", " start ++ ", " ++ joinString ++ " " ++ String.join "" end
