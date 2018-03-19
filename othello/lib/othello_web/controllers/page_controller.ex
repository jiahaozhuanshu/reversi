defmodule OthelloWeb.PageController do
  use OthelloWeb, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end

  def game(conn, params) do
    user_id = get_session(conn, :user_id)
    if user_id do
    render conn, "game.html", game: params["game"]
  else
    conn
    |> redirect(to: page_path(conn, :index))

  end
end

end
