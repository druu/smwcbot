defmodule SMWCWeb.PageController do
  use SMWCWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
