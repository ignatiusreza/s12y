module Api.Graphql.Schema.Argument exposing (..)

import Api.Graphql.Schema.Value as Value exposing (Value)
import String.Interpolate exposing (interpolate)


type Argument
    = Required String Value



-- BUILDER


required : String -> Value -> Argument
required fieldName value =
    Required fieldName value



-- SERIALIZER


serialize : List Argument -> String
serialize arguments =
    case arguments of
        [] ->
            ""

        _ ->
            interpolate "({0})" [ arguments |> List.map serializeArgument |> String.join ", " ]


serializeArgument : Argument -> String
serializeArgument (Required name value) =
    interpolate "{0}: {1}" [ name, Value.serialize value ]
