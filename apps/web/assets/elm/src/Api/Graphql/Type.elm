module Api.Graphql.Type exposing (..)


type alias Project =
    { id : String
    , dependencies : List Dependency
    , maintainers : List Maintainer
    }


type alias Dependency =
    { id : String
    , name : String
    , version : String
    }


type alias Maintainer =
    { id : String
    , handle : String
    , email : Maybe String
    }
