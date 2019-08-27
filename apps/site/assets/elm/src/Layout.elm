module Layout exposing (view)

import Browser
import Html exposing (..)



-- VIEW


view : { title : String, content : Html msg } -> Browser.Document msg
view { title, content } =
    { title = title ++ " -- s12y"
    , body = viewHeader :: content :: [ viewFooter ]
    }


viewHeader : Html msg
viewHeader =
    header [] [ text "this is a header" ]


viewFooter : Html msg
viewFooter =
    footer [] [ text "this is a footer" ]
