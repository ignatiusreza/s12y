defmodule S12yWeb.PageControllerTest do
  use S12yWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get(conn, "/")
    assert html_response(conn, 200) =~ "Loading..."
  end
end
