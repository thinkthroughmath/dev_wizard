defmodule DevWizard.PageController do
  use DevWizard.Web, :controller

  alias Phoenix.Controller.Flash
  alias DevWizard.GithubAuth
  alias DevWizard.GithubGateway
  alias DevWizard.IssueWorkflow

  def index(conn, _params) do
    conn
    |> assign(:current_user, get_session(conn, :current_user))
    |> render("index.html")
  end

  def dash(conn, _params) do
    require_login!(conn)

    user = get_session(conn, :current_user)

    todo = gh_client(conn)
      |> GithubGateway.needs_code_review
      |> IssueWorkflow.pr_todo(user[:login])

    conn
      |> assign(:current_user, user)
      |> assign(:prs_todo, todo)
      |> render("dash.html")
  end

  def needs_review(conn, _params) do
    require_login!(conn)

    user = get_session(conn, :current_user)

    needs_review = gh_client(conn)
      |> GithubGateway.needs_code_review

    conn
      |> assign(:current_user, user)
      |> assign(:needs_review, needs_review)
      |> render("needs_review.html")
  end

  def needs_qa(conn, _params) do
    require_login!(conn)

    user = get_session(conn, :current_user)

    needs_qa = gh_client(conn)
    |> GithubGateway.needs_qa

    conn
    |> assign(:current_user, user)
    |> assign(:needs_review, needs_qa)
    |> render("needs_review.html")
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

    is_member = GithubGateway.member_of_organization?(gh_client)

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
