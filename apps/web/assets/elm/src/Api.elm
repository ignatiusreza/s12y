module Api exposing (ApiResult, send)

import Api.Graphql.Schema as Schema exposing (Schema)
import Api.Graphql.Serializer exposing (HttpResult, toHttpPost)
import Http


type alias ApiResult decodesTo =
    HttpResult decodesTo


send : (HttpResult decodesTo -> msg) -> Schema decodesTo -> Cmd msg
send toMsg schema =
    schema
        |> toHttpPost toMsg
        |> (\a -> { body = a.body, expect = a.expect, url = endpoint })
        |> Http.post


endpoint : String
endpoint =
    "/api"
