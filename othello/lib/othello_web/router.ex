defmodule OthelloWeb.Router do
  use OthelloWeb, :router

  alias Othello.Accounts

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug :get_current_user
  end

  pipeline :api do
    plug :accepts, ["json"]
  end


  def get_current_user(conn, _params) do
    user_id = get_session(conn, :user_id)

    if user_id do
      user = Accounts.get_user!(user_id)
      assign(conn, :current_user, user)
    else
      assign(conn, :current_user, nil)
    end
  end

  scope "/", OthelloWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    get "/game/:game", PageController, :game
    resources "/users", UserController
    resources "/game", GamesController
    post "/session", SessionController, :create
    delete "/session", SessionController, :delete

  end

  # Other scopes may use custom stacks.
  # scope "/api", OthelloWeb do
  #   pipe_through :api
  # end
end
