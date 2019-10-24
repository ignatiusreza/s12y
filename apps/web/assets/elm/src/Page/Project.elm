module Page.Project exposing (Model, Msg(..), fetchProject, init, update, view)

import Api exposing (ApiResult)
import Api.Project exposing (Dependency, Maintainer, Project, createProject, getProject, initProject)
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
    case msg of
        Fetched result ->
            case result of
                Ok project ->
                    ( { model | state = RemoteData.Success project }, Cmd.none )

                Err err ->
                    ( { model | state = RemoteData.Failure err }, Cmd.none )



-- VIEW


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Project Page"
    , content = viewContent model
    }


viewContent : Model -> Html Msg
viewContent model =
    case model.state of
        RemoteData.NotAsked ->
            viewLoading model

        RemoteData.Loading ->
            viewLoading model

        RemoteData.Failure error ->
            viewError model error

        RemoteData.Success project ->
            viewProject project


viewLoading : Model -> Html Msg
viewLoading { params } =
    div
        []
        [ text ("Project Page " ++ params.projectId) ]


viewError : Model -> Http.Error -> Html Msg
viewError { params } error =
    div
        []
        [ text ("Error loading project " ++ params.projectId) ]


viewProject : Project -> Html Msg
viewProject { dependencies, maintainers } =
    div [] [ viewDependencies dependencies, viewMaintainers maintainers ]


viewDependencies : List Dependency -> Html Msg
viewDependencies dependencies =
    table
        []
        [ thead
            []
            [ tr
                []
                [ td [] [ text "Name" ]
                , td [] [ text "Version" ]
                ]
            ]
        , tbody
            []
            (dependencies |> List.map viewDependency)
        ]


viewDependency : Dependency -> Html Msg
viewDependency dependency =
    tr
        []
        [ td [] [ text dependency.name ]
        , td [] [ text dependency.version ]
        ]


viewMaintainers : List Maintainer -> Html Msg
viewMaintainers maintainers =
    table
        []
        [ thead
            []
            [ tr
                []
                [ td [] [ text "Handle" ]
                , td [] [ text "Email" ]
                ]
            ]
        , tbody
            []
            (maintainers |> List.map viewMaintainer)
        ]


viewMaintainer : Maintainer -> Html Msg
viewMaintainer maintainer =
    tr
        []
        [ td [] [ text maintainer.handle ]
        , td [] [ viewMaintainerEmail maintainer ]
        ]


viewMaintainerEmail : Maintainer -> Html Msg
viewMaintainerEmail maintainer =
    case maintainer.email of
        Just email ->
            text email

        Nothing ->
            text "n/a"


fetchProject : String -> Cmd Msg
fetchProject projectId =
    getProject projectId
        |> Api.send Fetched
