module Api.Graphql.Serializer exposing (HttpResult, toHttpPost)

import Api.Graphql.Schema as Schema exposing (Schema)
import Api.Graphql.Schema.Argument as Argument exposing (Argument)
import Api.Graphql.Schema.Field as Field exposing (Field)
import Api.Graphql.Schema.Value as Value exposing (Value)
import Debug exposing (todo)
import File exposing (File)
import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode


type alias HttpPost msg =
    { body : Http.Body
    , expect : Http.Expect msg
    }


type alias HttpResult decodesTo =
    Result Http.Error decodesTo


toHttpPost : (HttpResult decodesTo -> msg) -> Schema decodesTo -> HttpPost msg
toHttpPost toMsg schema =
    case schema of
        Schema.Query fields decoder ->
            toQueryRequest toMsg fields decoder

        Schema.Mutation fields decoder ->
            toMutationRequest toMsg fields decoder



-- QUERY


toQueryRequest : (HttpResult decodesTo -> msg) -> List Field -> Decoder decodesTo -> HttpPost msg
toQueryRequest toMsg fields decoder =
    { body = toQueryBody fields
    , expect = expectJson toMsg decoder
    }


toQueryBody : List Field -> Http.Body
toQueryBody fields =
    Http.jsonBody (Encode.object [ ( "query", Encode.string (Schema.serializeQuery fields) ) ])



-- MUTATION


toMutationRequest : (HttpResult decodesTo -> msg) -> List Field -> Decoder decodesTo -> HttpPost msg
toMutationRequest toMsg fields decoder =
    { body = toMutationBody fields
    , expect = expectJson toMsg decoder
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



-- EXPECTATION


expectJson : (HttpResult decodesTo -> msg) -> Decode.Decoder decodesTo -> Http.Expect msg
expectJson toMsg decoder =
    Http.expectStringResponse toMsg <|
        \response ->
            case response of
                Http.BadUrl_ url ->
                    Http.BadUrl url |> Err

                Http.Timeout_ ->
                    Http.Timeout |> Err

                Http.NetworkError_ ->
                    Http.NetworkError |> Err

                Http.BadStatus_ metadata body ->
                    Http.BadStatus metadata.statusCode |> Err

                Http.GoodStatus_ metadata body ->
                    case Decode.decodeString (Decode.field "data" decoder) body of
                        Ok value ->
                            Ok value

                        Err err ->
                            Http.BadBody (Decode.errorToString err) |> Err
