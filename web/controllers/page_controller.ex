defmodule DevWizard.PageController do
  use DevWizard.Web, :controller
  alias Phoenix.Controller.Flash

  @organization "ThinkThroughMath"
  @default_repo  "apangea"

  require IEx

  def index(conn, _params) do
    conn = assign(conn, :current_user, get_session(conn, :current_user))
    render conn, "index.html"
  end

  def dash(conn, _params) do
    require_login!(conn)

    involving = gh_client(conn)
      |> DevWizard.GithubGateway.pulls_involving_you

    conn
      |> assign(:prs_involving_you, involving)
      |> render "dash.html"
  end

  def login(conn, _params) do
    url = gh_auth_client
      |> DevWizard.GithubAuth.authorize_url

    redirect conn, external: url
  end

  def oauth_callback(conn, %{"code" => code}) do
    token = gh_auth_client
      |> DevWizard.GithubAuth.get_token_from_callback_code(code)

    tent_client = Tentacat.Client.new(%{access_token: token})

    user = Tentacat.Users.me(tent_client)
    user = %{name: user["name"], avatar: user["avatar_url"], login: user["login"]}

    is_member = DevWizard.GithubGateway.is_user_member_of_organization(token,
                                                                       @organization)
    if is_member do
      conn
        |> put_session(:current_user, user)
        |> put_session(:access_token, token)
        |> redirect(to: "/dash")
    else
      conn
        |> put_flash(:error, "You must be part of the #{@organization} organization.")
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
    settings = %{
      organization:       @organization,
      default_repository: @default_repo,
    }
    DevWizard.GithubGateway.new(get_session(conn, :access_token),
                                get_session(conn, :user),
                                settings)
  end

  defp gh_auth_client do
    settings = %{
      gh_client_id:       String.strip(System.get_env("GH_CLIENT_ID")),
      gh_client_secret:   String.strip(System.get_env("GH_CLIENT_SECRET")),
      gh_callback_uri:    String.strip(System.get_env("GH_CALLBACK_URL"))
    }
    DevWizard.GithubAuth.new settings
  end
end
