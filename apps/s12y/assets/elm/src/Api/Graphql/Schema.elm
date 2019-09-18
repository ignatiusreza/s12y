module Api.Graphql.Schema exposing (..)

import Api.Graphql.Schema.Argument exposing (Argument)
import Api.Graphql.Schema.Field as Field exposing (Field)
import Json.Decode as Decode exposing (Decoder)
import String.Interpolate exposing (interpolate)


type Schema decodesTo
    = Query (List Field) (Decoder decodesTo)
    | Mutation (List Field) (Decoder decodesTo)



-- BUILDER


query : List Field -> Decoder decodesTo -> Schema decodesTo
query fields decoder =
    Query fields decoder


mutation : List Field -> Decoder decodesTo -> Schema decodesTo
mutation fields decoder =
    Mutation fields decoder



-- SERIALIZER


serializeMutation : List Field -> String
serializeMutation fields =
    serialize "mutation" fields


serialize : String -> List Field -> String
serialize operation fields =
    interpolate
        """{0}{1}"""
        [ operation, Field.serialize 1 fields ]
