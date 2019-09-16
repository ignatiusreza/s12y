module Api.Graphql.Schema.Value exposing (..)

import File exposing (File)
import Json.Encode


type Value
    = File File
    | Json Json.Encode.Value
    | List (List Value)
    | Object (List ( String, Value ))


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
