module Api.Graphql.Query exposing (getProject)

import Api.Graphql.Schema as Schema exposing (Schema)
import Api.Graphql.Schema.Argument as Argument exposing (Argument)
import Api.Graphql.Schema.Field as Field
import Api.Graphql.Schema.Value as Value exposing (Value)
import Api.Graphql.Type exposing (Dependency, Maintainer, Project)
import Json.Decode as Decode exposing (Decoder)


getProject : String -> Schema Project
getProject projectId =
    Schema.query
        [ Field.inner "project"
            [ Argument.required "id" (Value.string projectId) ]
            [ Field.leaf "id" []
            , Field.inner "dependencies"
                []
                [ Field.leaf "id" []
                , Field.leaf "name" []
                , Field.leaf "version" []
                ]
            , Field.inner "maintainers"
                []
                [ Field.leaf "id" []
                , Field.leaf "handle" []
                , Field.leaf "email" []
                ]
            ]
        ]
    <|
        Decode.field "project"
            (Decode.map3 Project
                (Decode.field "id" Decode.string)
                (Decode.field "dependencies" (Decode.list dependencyDecoder))
                (Decode.field "maintainers" (Decode.list maintainerDecoder))
            )


dependencyDecoder : Decoder Dependency
dependencyDecoder =
    Decode.map3 Dependency
        (Decode.field "id" Decode.string)
        (Decode.field "name" Decode.string)
        (Decode.field "version" Decode.string)


maintainerDecoder : Decoder Maintainer
maintainerDecoder =
    Decode.map3 Maintainer
        (Decode.field "id" Decode.string)
        (Decode.field "handle" Decode.string)
        (Decode.maybe (Decode.field "email" Decode.string))
