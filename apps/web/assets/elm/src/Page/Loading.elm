module Page.Loading exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)



-- VIEW


view : { title : String, content : Html msg }
view =
    { title = "Loading..."
    , content =
        div
            [ class "flex items-center justify-center h-screen w-full" ]
            [ h1
                [ class "text-3xl font-bold tracking-semi-tight" ]
                [ text "Loading..." ]
            ]
    }
