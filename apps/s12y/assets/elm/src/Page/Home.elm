module Page.Home exposing (Model, Msg(..), init, update, view)

import Api
import Api.Project exposing (createProject)
import File exposing (File)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
import RemoteData exposing (RemoteData)



-- MODEL


type alias Model =
    RemoteData Http.Error ()


init : Model
init =
    RemoteData.NotAsked



-- UPDATE


type Msg
    = FileSelected (List File)
    | FileUploaded (Result Http.Error ())


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FileSelected [ file ] ->
            ( RemoteData.Loading
            , uploadFile file
            )

        FileSelected _ ->
            ( RemoteData.NotAsked, Cmd.none )

        FileUploaded result ->
            case result of
                Ok _ ->
                    ( RemoteData.Success (), Cmd.none )

                Err e ->
                    ( RemoteData.Failure e, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Home Page"
    , content =
        input
            [ type_ "file"
            , on "change" (Json.map FileSelected filesDecoder)
            ]
            []
    }



-- HELPERS


filesDecoder : Json.Decoder (List File)
filesDecoder =
    Json.at [ "target", "files" ] (Json.list File.decoder)


uploadFile : File -> Cmd Msg
uploadFile file =
    createProject file
        |> Api.send FileUploaded
