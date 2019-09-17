module Api.Graphql.Schema exposing (..)

import Api.Graphql.Schema.Argument exposing (Argument)
import Api.Graphql.Schema.Field as Field exposing (Field)
import Json.Decode as Decode exposing (Decoder)
import String.Interpolate exposing (interpolate)


type Schema
    = Query (List Field)
    | Mutation (List Field)



-- BUILDER


query : List Field -> Schema
query fields =
    Query fields


mutation : List Field -> Schema
mutation fields =
    Mutation fields



-- SERIALIZER


serializeMutation : List Field -> String
serializeMutation fields =
    serialize "mutation" fields


serialize : String -> List Field -> String
serialize operation fields =
    interpolate
        """{0}{1}"""
        [ operation, Field.serialize 1 fields ]
