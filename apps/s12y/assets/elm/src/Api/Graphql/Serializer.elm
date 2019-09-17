module Api.Graphql.Serializer exposing (toHttpPost)

import Api.Graphql.Schema as Schema exposing (Schema)
import Api.Graphql.Schema.Argument as Argument exposing (Argument)
import Api.Graphql.Schema.Field as Field exposing (Field)
import Api.Graphql.Schema.Value as Value exposing (Value)
import Debug exposing (todo)
import File exposing (File)
import Http


type alias HttpPost msg =
    { body : Http.Body
    , expect : Http.Expect msg
    }


type alias HttpResult msg =
    Result Http.Error () -> msg


toHttpPost : HttpResult msg -> Schema -> HttpPost msg
toHttpPost toMsg schema =
    case schema of
        Schema.Query fields ->
            toQueryRequest toMsg fields

        Schema.Mutation fields ->
            toMutationRequest toMsg fields



-- QUERY


toQueryRequest : HttpResult msg -> List Field -> HttpPost msg
toQueryRequest toMsg fields =
    { body = todo "Add support for query request"
    , expect = Http.expectWhatever toMsg
    }



-- MUTATION


toMutationRequest : HttpResult msg -> List Field -> HttpPost msg
toMutationRequest toMsg fields =
    { body = toMutationBody fields
    , expect = Http.expectWhatever toMsg
    }


toMutationBody : List Field -> Http.Body
toMutationBody fields =
    [ Http.stringPart "query" (Schema.serializeMutation fields) ]
        |> Http.multipartBody
