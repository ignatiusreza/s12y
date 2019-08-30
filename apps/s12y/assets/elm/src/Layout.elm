module Layout exposing (view)

import Browser
import Component.Svg as Svg exposing (view)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Entity exposing (copy)



-- VIEW


view : { title : String, content : Html msg } -> Browser.Document msg
view { title, content } =
    { title = title ++ " -- s12y"
    , body = viewHeader :: content :: [ viewFooter ]
    }


viewHeader : Html msg
viewHeader =
    header
        []
        [ a
            [ href "/" ]
            [ Svg.view [] Svg.Logo ]
        , a
            [ href "https://github.com/ignatiusreza/s12y"
            , target "_blank"
            ]
            [ Svg.view [] Svg.Github ]
        ]


viewFooter : Html msg
viewFooter =
    footer [] [ text (copy ++ " Copyright s12y, 2019 - Present") ]
