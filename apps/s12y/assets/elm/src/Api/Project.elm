module Api.Project exposing (Response, createProject)

import Api.Graphql.InputObject as InputObject
import Api.Graphql.Mutation as Mutation
import Api.Graphql.Scalar as Scalar
import File exposing (File)
import Graphql.Operation
import Graphql.OptionalArgument as OptionalArgument
import Graphql.SelectionSet as SelectionSet exposing (SelectionSet)


type alias Project =
    { id : String }


type alias Response =
    Maybe ()


createProject : File -> SelectionSet (Maybe ()) Graphql.Operation.RootMutation
createProject file =
    Mutation.createProject (Mutation.CreateProjectRequiredArguments (buildConfigurations file)) SelectionSet.empty


buildConfigurations : File -> List (Maybe InputObject.ConfigurationInput)
buildConfigurations file =
    [ Just (InputObject.buildConfigurationInput { content = Scalar.Upload "upload", filename = File.name file }) ]
