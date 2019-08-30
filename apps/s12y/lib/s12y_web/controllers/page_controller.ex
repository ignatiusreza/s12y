defmodule S12yWeb.PageController do
  use S12yWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
