module Api.Graphql.Mutation exposing (ConfigurationInput, CreateProjectArguments, createProject)

import Api.Graphql.Schema as Schema exposing (Schema)
import Api.Graphql.Schema.Argument as Argument exposing (Argument)
import Api.Graphql.Schema.Field as Field
import Api.Graphql.Schema.Value as Value exposing (Value)
import File exposing (File)


type alias ConfigurationInput =
    { filename : String
    , content : File
    }


type alias CreateProjectArguments =
    { configurations : List ConfigurationInput }


createProject : CreateProjectArguments -> Schema
createProject arguments =
    [ Field.inner "createProject"
        [ Argument.required "configurations" (Value.list encodeConfigurationInput arguments.configurations) ]
        [ Field.leaf "id" [] ]
    ]
        |> Schema.mutation


encodeConfigurationInput : ConfigurationInput -> Value
encodeConfigurationInput input =
    Value.Object
        [ ( "filename", Value.string input.filename )
        , ( "content", Value.file input.content )
        ]
