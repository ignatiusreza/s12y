defmodule S12yWeb.Router do
  use S12yWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", S12yWeb do
    pipe_through :browser

    get "/", PageController, :index
  end

  # Other scopes may use custom stacks.
  # scope "/api", S12yWeb do
  #   pipe_through :api
  # end

  forward "/api", Absinthe.Plug, schema: S12yWeb.Schema

  if Mix.env() == :dev do
    forward "/graphiql", Absinthe.Plug.GraphiQL, schema: S12yWeb.Schema
  end
end
