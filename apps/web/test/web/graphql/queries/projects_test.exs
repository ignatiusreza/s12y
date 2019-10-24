defmodule Web.GraphQL.ProjectTest do
  use Web.GraphQLCase, async: true
  use S12yWeb.Fixture

  test "fetching project with configurations", %{conn: conn} do
    project = project_fixture()
    [configuration | _] = project.configurations

    response =
      conn
      |> graphql_query("""
        {
          project(id: "#{project.id}") {
            id
            configurations {
              id
            }
          }
        }
      """)

    assert json_response(response, 200) == %{
             "data" => %{
               "project" => %{
                 "id" => project.id,
                 "configurations" => [%{"id" => Integer.to_string(configuration.id)}]
               }
             }
           }
  end

  test "fetching project dependencies", %{conn: conn} do
    {:ok, %{project: project, dependency: dependency}} = dependency_fixture()

    response =
      conn
      |> graphql_query("""
        {
          project(id: "#{project.id}") {
            id
            dependencies {
              id
            }
          }
        }
      """)

    assert json_response(response, 200) == %{
             "data" => %{
               "project" => %{
                 "id" => project.id,
                 "dependencies" => [%{"id" => Integer.to_string(dependency.id)}]
               }
             }
           }
  end

  test "fetching project maintainers", %{conn: conn} do
    {:ok, %{project: project, dependency: dependency}} = maintainer_fixture()

    response =
      conn
      |> graphql_query("""
        {
          project(id: "#{project.id}") {
            id
            maintainers {
              id
            }
          }
        }
      """)

    assert json_response(response, 200) == %{
             "data" => %{
               "project" => %{
                 "id" => project.id,
                 "maintainers" =>
                   Enum.map(dependency.maintainers, fn maintainer ->
                     %{"id" => Integer.to_string(maintainer.id)}
                   end)
               }
             }
           }
  end

  test "creating project", %{conn: conn} do
    fixture = fixture_path("parsers/mix/mix_new/input")

    response =
      conn
      |> graphql_fixture_upload(
        """
          mutation {
            createProject(
              configurations: [{filename: "mix.exs", content: "upload"}]
            ) {
              id
            }
          }
        """,
        fixture
      )

    assert %{
             "data" => %{
               "createProject" => %{
                 "id" => string
               }
             }
           } = json_response(response, 200)
  end
end
