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
    fields
        |> extractFiles
        |> filesPart
        |> List.append [ Http.stringPart "query" (Schema.serializeMutation fields) ]
        |> Http.multipartBody



-- MUTATION WITH FILES


extractFiles : List Field -> List File
extractFiles fields =
    fields
        |> List.foldl extractFilesFromField []


extractFilesFromField : Field -> List File -> List File
extractFilesFromField field files =
    case field of
        Field.Inner name arguments children ->
            extractFilesFromField (Field.Leaf name arguments) files

        Field.Leaf name arguments ->
            arguments
                |> List.foldl extractFilesFromArgument files


extractFilesFromArgument : Argument -> List File -> List File
extractFilesFromArgument (Argument.Required _ value) files =
    extractFilesFromValue files value


extractFilesFromValue : List File -> Value -> List File
extractFilesFromValue files value =
    case value of
        Value.File file ->
            files ++ [ file ]

        Value.List values ->
            values
                |> List.map (extractFilesFromValue files)
                |> List.concat
                |> List.append files

        Value.Object object ->
            object
                |> List.map (\( k, v ) -> extractFilesFromValue files v)
                |> List.concat
                |> List.append files

        _ ->
            files


filesPart : List File -> List Http.Part
filesPart files =
    case files of
        [] ->
            []

        [ file ] ->
            [ Http.filePart "upload" file ]

        file :: _ ->
            todo "Uploading multiple files is not yet supported" (filesPart [ file ])
