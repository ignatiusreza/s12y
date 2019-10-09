module Api.Graphql.Schema.Value exposing (..)

import File exposing (File)
import Json.Encode
import String.Interpolate exposing (interpolate)


type Value
    = File File
    | Json Json.Encode.Value
    | List (List Value)
    | Object (List ( String, Value ))



-- BUILDER


file : File -> Value
file value =
    File value


list : (a -> Value) -> List a -> Value
list toValue value =
    value
        |> List.map toValue
        |> List


string : String -> Value
string value =
    Json.Encode.string value
        |> Json



-- SERIALIZER


serialize : Value -> String
serialize value =
    case value of
        File _ ->
            serialize (Json (Json.Encode.string "upload"))

        Json json ->
            Json.Encode.encode 0 json

        List values ->
            [ values |> List.map serialize |> String.join ", " ]
                |> interpolate "[{0}]"

        Object object ->
            [ object |> List.map (\( k, v ) -> interpolate "{0}: {1}" [ k, serialize v ]) |> String.join ", " ]
                |> interpolate "{{0}}"
