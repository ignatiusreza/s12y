module Layout exposing (view)

import Browser
import Component.Svg as Svg
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Entity exposing (copy)
import Html.Lazy exposing (lazy)



-- VIEW


view : { title : String, content : Html msg } -> Browser.Document msg
view { title, content } =
    { title = title ++ " -- s12y"
    , body = svgRoot :: viewHeader :: content :: [ viewFooter ]
    }


svgRoot : Html msg
svgRoot =
    lazy (\a -> div [ id "svg-root" ] a) []


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
