defmodule S12yWeb.GraphQLCase do
  @moduledoc """
  Test helpers for GraphQL test.
  """

  import Plug.Conn

  defmacro __using__(args) do
    quote do
      use S12yWeb.ConnCase, unquote(args)
      import S12yWeb.GraphQLCase

      @graphql_endpoint "/api"

      defmacro graphql_query(conn, query) do
        quote do
          unquote(conn)
          |> put_graphql_headers()
          |> post(@graphql_endpoint, unquote(query))
        end
      end

      defmacro graphql_fixture_upload(conn, query, fixture) do
        quote do
          upload = %Plug.Upload{path: unquote(fixture)}

          unquote(conn)
          |> post(@graphql_endpoint, %{query: unquote(query), upload: upload})
        end
      end
    end
  end

  def put_graphql_headers(conn) do
    conn
    |> put_req_header("content-type", "application/graphql")
  end
end
