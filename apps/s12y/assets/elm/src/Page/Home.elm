module Page.Home exposing (Msg, view)

import Html exposing (..)



-- UPDATE


type Msg
    = NoOp



-- VIEW


view : { title : String, content : Html Msg }
view =
    { title = "Home Page"
    , content =
        div [] [ text "Home Page" ]
    }
