module Route exposing (Route(..), fromUrl)

import Browser.Navigation as Nav
import Page.Home
import Page.Project
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, map, oneOf, parse, s, string, top)


type Route
    = Loading
    | Home Page.Home.Model
    | Project Page.Project.Model
    | NotFound


type ParsedRoute
    = HomeUrl
    | ProjectUrl String


fromUrl : Nav.Key -> Url -> Maybe Route
fromUrl navKey url =
    case parse parser url of
        Just HomeUrl ->
            Just (Home (Page.Home.init navKey))

        Just (ProjectUrl projectId) ->
            Just (Project (Page.Project.init projectId))

        Nothing ->
            Nothing


parser : Parser (ParsedRoute -> a) a
parser =
    oneOf
        [ map HomeUrl top
        , map ProjectUrl (s "projects" </> string)
        ]
