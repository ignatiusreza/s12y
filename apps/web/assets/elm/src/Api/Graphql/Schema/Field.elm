module Api.Graphql.Schema.Field exposing (..)

import Api.Graphql.Schema.Argument as Argument exposing (Argument)
import String.Interpolate exposing (interpolate)


type Field
    = Inner String (List Argument) (List Field)
    | Leaf String (List Argument)



-- BUILDER


inner : String -> List Argument -> List Field -> Field
inner name arguments fields =
    Inner name arguments fields


leaf : String -> List Argument -> Field
leaf name arguments =
    Leaf name arguments



-- SERIALIZER


serialize : Int -> List Field -> String
serialize indentation fields =
    case fields of
        [] ->
            ""

        _ ->
            fields
                |> List.map (serializeField indentation)
                |> String.join "\n"
                |> (\a -> [ a, String.repeat (indentation - 1) "  " ])
                |> interpolate " {\n{0}\n{1}}"


serializeField : Int -> Field -> String
serializeField indentation field =
    case field of
        Inner name arguments fields ->
            serializeField indentation (Leaf name arguments) ++ serialize (indentation + 1) fields

        Leaf name arguments ->
            String.repeat indentation "  " ++ name ++ Argument.serialize arguments
