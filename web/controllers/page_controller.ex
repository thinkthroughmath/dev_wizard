defmodule DevWizard.PageController do
  use DevWizard.Web, :controller

  alias Phoenix.Controller.Flash
  alias DevWizard.GithubAuth
  alias DevWizard.GithubGateway

  def index(conn, _params) do
    conn
    |> assign(:current_user, get_session(conn, :current_user))
    |> render "index.html"
  end

  def dash(conn, _params) do
    require_login!(conn)

    involving = gh_client(conn)
      |> GithubGateway.pulls_involving_you

    conn
      |> assign(:current_user, get_session(conn, :current_user))
      |> assign(:prs_involving_you, involving)
      |> render "dash.html"
  end

  def pr_todo(conn, _params) do
    require_login!(conn)

    todo = gh_client(conn)
      |> GithubGateway.pr_todo

    conn
      |> assign(:current_user, get_session(conn, :current_user))
      |> assign(:prs_todo, todo)
      |> render "todo.html"
  end


  def login(conn, _params) do
    url = gh_auth_client
      |> GithubAuth.authorize_url

    redirect conn, external: url
  end

  def oauth_callback(conn, %{"code" => code}) do
    gh_client = gh_auth_client
      |> GithubAuth.get_token_from_callback_code(code)
      |> GithubGateway.new

    is_member = GithubGateway.is_user_member_of_organization(gh_client)

    if is_member do
      conn
        |> put_session(:current_user, gh_client.user)
        |> put_session(:access_token, gh_client.token)
        |> redirect(to: "/dash")
    else
      conn
        |> put_flash(:error, "You must be part of the #{gh_client.settings[:organization]} organization.")
        |> redirect(to: "/")
    end
  end

  defp require_login!(conn) do
    unless get_session(conn, :current_user) do
      conn
        |> put_flash(:error, "you must be logged in!!!!!!!!!!!")
        |> redirect(to: "/")
    end
  end

  defp gh_client(conn) do
    GithubGateway.new(get_session(conn, :access_token))
  end

  defp gh_auth_client do
    GithubAuth.new
  end
end
