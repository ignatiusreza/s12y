module Api.Project exposing (createProject)

import Api.Graphql.Mutation as Mutation exposing (ConfigurationInput, CreateProjectArguments)
import Api.Graphql.Schema exposing (Schema)
import File exposing (File, name)


createProject : File -> Schema
createProject file =
    Mutation.createProject (createProjectArguments file)


createProjectArguments : File -> CreateProjectArguments
createProjectArguments file =
    CreateProjectArguments [ ConfigurationInput (name file) file ]
