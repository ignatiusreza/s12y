module Api.Project exposing (Dependency, Maintainer, Project, createProject, getProject, initProject)

import Api.Graphql.Mutation as Mutation exposing (ConfigurationInput, CreateProjectArguments)
import Api.Graphql.Query as Query
import Api.Graphql.Schema exposing (Schema)
import Api.Graphql.Type as Type
import File exposing (File, name)


type alias Project =
    Type.Project


type alias Dependency =
    Type.Dependency


type alias Maintainer =
    Type.Maintainer


initProject : String -> Project
initProject projectId =
    Type.Project projectId [] []


getProject : String -> Schema Project
getProject projectId =
    Query.getProject projectId


createProject : File -> Schema Project
createProject file =
    Mutation.createProject (createProjectArguments file)


createProjectArguments : File -> CreateProjectArguments
createProjectArguments file =
    CreateProjectArguments [ ConfigurationInput (name file) file ]
