module Api.Graphql.Serializer exposing (toHttpPost)

import Api.Graphql.Schema as Schema exposing (Schema)
import Api.Graphql.Schema.Field as Field exposing (Field)
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
    { body = Http.emptyBody -- TODO: work on this when we actually need to
    , expect = Http.expectWhatever toMsg
    }



-- MUTATION


toMutationRequest : HttpResult msg -> List Field -> HttpPost msg
toMutationRequest toMsg fields =
    { body = Http.emptyBody
    , expect = Http.expectWhatever toMsg
    }
