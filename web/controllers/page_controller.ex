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

  def login(conn, _params) do
    perms = "user,public_repo,read:org,repo"
    url = client
      |> OAuth2.Client.put_param(:scope, perms)
      |> OAuth2.Client.authorize_url!([])

    redirect conn, external: url
  end

  def dash(conn, _params) do
    unless get_session(conn, :current_user) do
      conn
        |> put_flash(:error, "you must be logged in!!!!!!!!!!!")
        |> redirect(to: "/")
    end
    user = get_session(conn, :current_user)
    client = tentacat_client(conn)
    conn
      |> assign(:farted_out, inspect(Tentacat.Pulls.filter(@organization, @default_repo, %{author: user[:login]}, client)))
      |> render "dash.html"
  end

  def oauth_callback(conn, %{"code" => code}) do
    # Exchange an auth code for an access token
    token = client
      |> OAuth2.Client.put_header("Accept", "application/json")
      |> OAuth2.Client.get_token!(code: code)

    {:ok, %{body: user}} = OAuth2.AccessToken.get(token, "/user")
    user2 = %{name: user["name"], avatar: user["avatar_url"], login: user["login"]}


    tent_client = Tentacat.Client.new(%{access_token: token.access_token})
    is_member = Tentacat.Organizations.Members.member?(@organization, user["login"], tent_client)

    case is_member do
      {204, _} ->
        conn
          |> put_session(:current_user, user2)
          |> put_session(:access_token, token.access_token)
          |> redirect(to: "/dash")
      _ ->
        conn
          |> put_flash(:error, "You must be part of the #{@organization} organization.")
          |> redirect(to: "/")
    end
  end

  def tentacat_client(conn) do
    Tentacat.Client.new(%{access_token: get_session(conn, :access_token)})
  end

  def config do
    [
      site: "https://api.github.com",
      authorize_url: "https://github.com/login/oauth/authorize",
      token_url: "https://github.com/login/oauth/access_token",
      strategy: OAuth2.Strategy.AuthCode, #default
      client_id: String.strip(System.get_env("GH_CLIENT_ID")),
      client_secret: String.strip(System.get_env("GH_CLIENT_SECRET")),
      redirect_uri: String.strip(System.get_env("GH_CALLBACK_URL"))
    ]
  end

  def client do
    OAuth2.Client.new(config)
  end
end
