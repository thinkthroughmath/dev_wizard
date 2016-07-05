defmodule DevWizard.PageController do
  use DevWizard.Web, :controller

  alias DevWizard.GithubAuth
  alias DevWizard.GithubGateway
  alias DevWizard.IssueWorkflow

  def index(conn, _params) do
    conn
    |> assign(:current_user, get_session(conn, :current_user))
    |> render("index.html")
  end

  def my_code_reviews(conn, _params) do
    require_login!(conn)

    user       = get_session(conn, :current_user)
    gateway    = gh_client(conn)
    storyboard = gateway |> GithubGateway.storyboard_issues

    issues =
      gateway
      |> GithubGateway.needs_code_review
      |> IssueWorkflow.pr_todo(user[:login])
      |> IssueWorkflow.determine_milestone(storyboard)

    conn
      |> assign(:current_user, user)
      |> assign(:prs_todo, issues)
      |> render("my_code_reviews.html")
  end

  def needs_review(conn, _params) do
    require_login!(conn)

    user = get_session(conn, :current_user)

    page_title = "Needs Review"

    gateway    = gh_client(conn)
    storyboard = gateway |> GithubGateway.storyboard_issues

    issues =
      gateway
      |> GithubGateway.needs_code_review
      |> IssueWorkflow.determine_assignees
      |> IssueWorkflow.determine_milestone(storyboard)

    conn
      |> assign(:current_user, user)
      |> assign(:page_title, page_title)
      |> assign(:issue_list, issues)
      |> render("issue_list.html")
  end

  def needs_qa(conn, _params) do
    require_login!(conn)

    user = get_session(conn, :current_user)

    page_title = "Needs QA"

    gateway    = gh_client(conn)
    storyboard = gateway |> GithubGateway.storyboard_issues

    issues =
      gateway
      |> GithubGateway.needs_qa
      |> IssueWorkflow.determine_assignees
      |> IssueWorkflow.determine_milestone(storyboard)

    conn
    |> assign(:current_user, user)
    |> assign(:page_title, page_title)
    |> assign(:issue_list, issues)
    |> render("issue_list.html")
  end

  def needs_release_notes(conn, _params) do
    require_login!(conn)

    user = get_session(conn, :current_user)

    page_title = "Needs Release Notes"

    gateway    = gh_client(conn)
    storyboard = gateway |> GithubGateway.storyboard_issues

    issues =
      gateway
      |> GithubGateway.needs_release_notes
      |> IssueWorkflow.determine_assignees
      |> IssueWorkflow.determine_milestone(storyboard)

    conn
    |> assign(:current_user, user)
    |> assign(:page_title, page_title)
    |> assign(:issue_list, issues)
    |> render("issue_list.html")
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
        |> redirect(to: "/my_code_reviews")
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
