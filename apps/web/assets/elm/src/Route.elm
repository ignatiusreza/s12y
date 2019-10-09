module Route exposing (Route(..), fromUrl)

import Page.Home
import Url exposing (Url)
import Url.Parser as Parser exposing (Parser, oneOf)


type Route
    = Loading
    | Home Page.Home.Model
    | NotFound


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map (Home Page.Home.init) Parser.top
        ]
