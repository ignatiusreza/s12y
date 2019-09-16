module Api.Graphql.Schema.Argument exposing (..)

import Api.Graphql.Schema.Value exposing (Value)


type Argument
    = Required String Value


required : String -> Value -> Argument
required fieldName value =
    Required fieldName value
