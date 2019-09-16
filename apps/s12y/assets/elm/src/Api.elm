module Api exposing (send)

import Api.Graphql.Schema as Schema exposing (Schema)
import Api.Graphql.Serializer exposing (toHttpPost)
import Http


send : (Result Http.Error () -> msg) -> Schema -> Cmd msg
send toMsg schema =
    schema
        |> toHttpPost toMsg
        |> (\a -> { body = a.body, expect = a.expect, url = endpoint })
        |> Http.post


endpoint : String
endpoint =
    "/api"
