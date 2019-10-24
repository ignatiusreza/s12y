module Page.Home exposing (Model, Msg(..), init, update, view)

import Api exposing (ApiResult)
import Api.Project exposing (Project, createProject)
import Browser.Navigation as Nav
import File exposing (File)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
import RemoteData exposing (RemoteData)



-- MODEL


type alias Model =
    { navKey : Nav.Key
    , state : RemoteData Http.Error Project
    }


init : Nav.Key -> Model
init navKey =
    { navKey = navKey, state = RemoteData.NotAsked }



-- UPDATE


type Msg
    = FileSelected (List File)
    | FileUploaded (ApiResult Project)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        FileSelected [ file ] ->
            ( { model | state = RemoteData.Loading }
            , uploadFile file
            )

        FileSelected _ ->
            ( { model | state = RemoteData.NotAsked }, Cmd.none )

        FileUploaded result ->
            case result of
                Ok project ->
                    ( { model | state = RemoteData.Success project }
                    , Nav.pushUrl model.navKey ("/projects/" ++ project.id)
                    )

                Err err ->
                    ( { model | state = RemoteData.Failure err }, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Home Page"
    , content = viewContent model
    }


viewContent : Model -> Html Msg
viewContent model =
    case model.state of
        RemoteData.NotAsked ->
            input
                [ type_ "file"
                , on "change" (Json.map FileSelected filesDecoder)
                ]
                []

        RemoteData.Loading ->
            div [] [ text "Uploading..." ]

        RemoteData.Success project ->
            div [] [ text ("Uploaded: " ++ project.id) ]

        RemoteData.Failure err ->
            case err of
                Http.BadUrl msg ->
                    text ("Error: BadUrl(" ++ msg ++ ")")

                Http.Timeout ->
                    text "Error: Timeout"

                Http.NetworkError ->
                    text "Error: NetworkError"

                Http.BadStatus status ->
                    text ("Error: BadStatus(" ++ String.fromInt status ++ ")")

                Http.BadBody msg ->
                    text ("Error: BadBody(" ++ msg ++ ")")



-- HELPERS


filesDecoder : Json.Decoder (List File)
filesDecoder =
    Json.at [ "target", "files" ] (Json.list File.decoder)


uploadFile : File -> Cmd Msg
uploadFile file =
    createProject file
        |> Api.send FileUploaded
