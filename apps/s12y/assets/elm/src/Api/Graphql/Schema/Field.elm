module Api.Graphql.Schema.Field exposing (..)

import Api.Graphql.Schema.Argument as Argument exposing (Argument)


type Field
    = Inner String (List Argument) (List Field)
    | Leaf String (List Argument)



-- BUILDER


inner : String -> List Argument -> List Field -> Field
inner name arguments fields =
    Inner name arguments fields


leaf : String -> List Argument -> Field
leaf name arguments =
    Leaf name arguments

