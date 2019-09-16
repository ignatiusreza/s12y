module Api exposing (endpoint)

import File exposing (File)
import Graphql.Http exposing (Error, Request)
import Graphql.Http.GraphqlError as GraphqlError
import Http
import Json.Decode


endpoint : String
endpoint =
    "/api"
