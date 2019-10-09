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
