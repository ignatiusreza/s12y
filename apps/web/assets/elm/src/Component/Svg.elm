module Component.Svg exposing (Svg(..), view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Svg exposing (svg, use)
import Svg.Attributes exposing (xlinkHref)


type Svg
    = Logo
    | Github


view : List (Html.Attribute msg) -> Svg -> Html msg
view attributes id =
    svg
        (List.concat [ attributes, svgStyle id ])
        [ use [ xlinkHref ("#" ++ idToString id) ] [] ]


svgStyle : Svg -> List (Html.Attribute msg)
svgStyle id =
    case id of
        Logo ->
            [ style "width" "3rem"
            , style "height" "2rem"
            ]

        _ ->
            [ style "width" "2rem"
            , style "width" "2rem"
            ]


idToString : Svg -> String
idToString id =
    case id of
        Logo ->
            "logo"

        Github ->
            "github"
