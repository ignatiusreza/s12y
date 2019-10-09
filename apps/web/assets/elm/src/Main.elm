module Main exposing (main)

import Browser
import Browser.Navigation as Nav
import Html exposing (..)
import Layout
import Page.Home
import Page.Loading
import Page.NotFound
import Route exposing (Route)
import Url exposing (Url)



-- MODEL


type alias Model =
    { navKey : Nav.Key
    , route : Route
    }


type Msg
    = NoOp
    | UrlChanged Url
    | UrlRequested Browser.UrlRequest
    | HomeMsg Page.Home.Msg


initialModel : Nav.Key -> Model
initialModel navKey =
    Model navKey Route.Loading


main : Program () Model Msg
main =
    Browser.application
        { init = init
        , subscriptions = subscriptions
        , onUrlChange = UrlChanged
        , onUrlRequest = UrlRequested
        , update = update
        , view = view
        }


init : () -> Url -> Nav.Key -> ( Model, Cmd Msg )
init () url navKey =
    routeTo url (initialModel navKey)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- UPDATE


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model.route ) of
        ( HomeMsg homeMsg, Route.Home homeModel ) ->
            homeModel
                |> Page.Home.update homeMsg
                |> updateRoute Route.Home HomeMsg model

        ( _, _ ) ->
            ( model, Cmd.none )


updateRoute : (a -> Route) -> (b -> Msg) -> Model -> ( a, Cmd b ) -> ( Model, Cmd Msg )
updateRoute toRoute toMsg model ( pageModel, pageCmd ) =
    ( { model | route = toRoute pageModel }
    , Cmd.map toMsg pageCmd
    )



-- VIEW


view : Model -> Browser.Document Msg
view model =
    case model.route of
        Route.Loading ->
            viewPage Page.Loading.view

        Route.Home homeModel ->
            viewPage2 (Page.Home.view homeModel) HomeMsg

        Route.NotFound ->
            viewPage Page.NotFound.view


viewPage : { title : String, content : Html msg } -> Browser.Document Msg
viewPage page =
    viewPage2 page (\msg -> NoOp)


viewPage2 : { title : String, content : Html msg } -> (msg -> Msg) -> Browser.Document Msg
viewPage2 page toMsg =
    let
        { title, body } =
            Layout.view page
    in
    { title = title
    , body = List.map (Html.map toMsg) body
    }



-- HELPERS


routeTo : Url -> Model -> ( Model, Cmd Msg )
routeTo url model =
    let
        maybeRoute =
            Route.fromUrl url
    in
    case maybeRoute of
        Nothing ->
            ( { model | route = Route.NotFound }, Cmd.none )

        Just route ->
            ( { model | route = route }, Cmd.none )
