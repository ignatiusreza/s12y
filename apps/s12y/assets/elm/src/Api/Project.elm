module Api.Project exposing (Project, createProject)

import Api.Graphql.Mutation as Mutation exposing (ConfigurationInput, CreateProjectArguments)
import Api.Graphql.Schema exposing (Schema)
import Api.Graphql.Type as Type
import File exposing (File, name)


type alias Project =
    Type.Project


createProject : File -> Schema Project
createProject file =
    Mutation.createProject (createProjectArguments file)


createProjectArguments : File -> CreateProjectArguments
createProjectArguments file =
    CreateProjectArguments [ ConfigurationInput (name file) file ]
