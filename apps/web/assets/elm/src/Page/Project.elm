module Page.Project exposing (Model, Msg(..), init, update, view)

import Api exposing (ApiResult)
import Api.Project exposing (Project, createProject)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Http
import Json.Decode as Json
import RemoteData exposing (RemoteData)



-- MODEL


type alias Model =
    { params : { projectId : String }
    , state : RemoteData Http.Error Project
    }


init : String -> Model
init projectId =
    { params = { projectId = projectId }, state = RemoteData.NotAsked }



-- UPDATE


type Msg
    = Fetched (ApiResult Project)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    ( model, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Project Page"
    , content = viewContent model
    }


viewContent : Model -> Html Msg
viewContent model =
    viewLoading model


viewLoading : Model -> Html Msg
viewLoading { params } =
    div
        []
        [ text ("Project Page " ++ params.projectId) ]
