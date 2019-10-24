module Api.Graphql.Mutation exposing (ConfigurationInput, CreateProjectArguments, createProject)

import Api.Graphql.Schema as Schema exposing (Schema)
import Api.Graphql.Schema.Argument as Argument exposing (Argument)
import Api.Graphql.Schema.Field as Field
import Api.Graphql.Schema.Value as Value exposing (Value)
import Api.Graphql.Type exposing (Project)
import File exposing (File)
import Json.Decode as Decode


type alias ConfigurationInput =
    { filename : String
    , content : File
    }


type alias CreateProjectArguments =
    { configurations : List ConfigurationInput }


createProject : CreateProjectArguments -> Schema Project
createProject arguments =
    Schema.mutation
        [ Field.inner "createProject"
            [ Argument.required "configurations" (Value.list encodeConfigurationInput arguments.configurations) ]
            [ Field.leaf "id" [] ]
        ]
    <|
        Decode.field "createProject"
            (Decode.map3 Project
                (Decode.field "id" Decode.string)
                (Decode.succeed [])
                (Decode.succeed [])
            )


encodeConfigurationInput : ConfigurationInput -> Value
encodeConfigurationInput input =
    Value.Object
        [ ( "filename", Value.string input.filename )
        , ( "content", Value.file input.content )
        ]
