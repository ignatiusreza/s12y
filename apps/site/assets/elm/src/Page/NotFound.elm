module Page.NotFound exposing (view)

import Html exposing (..)



-- VIEW


view : { title : String, content : Html msg }
view =
    { title = "404 Not Found"
    , content =
        div [] [ text "404 Not Found" ]
    }
