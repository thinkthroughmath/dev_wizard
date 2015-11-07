defmodule DevWizard.PageController do
  use DevWizard.Web, :controller
  require IEx
  def index(conn, _params) do
    conn = assign(conn, :current_user, get_session(conn, :current_user))
    render conn, "index.html"
  end

  def login(conn, _params) do
    redirect conn, external: OAuth2.Client.authorize_url!(client, [])
  end

  def oauth_callback(conn, %{"code" => code}) do
    # Exchange an auth code for an access token
    token = client
      |> OAuth2.Client.put_header("Accept", "application/json")
      |> OAuth2.Client.get_token!(code: code)
    {:ok, %{body: user}} = OAuth2.AccessToken.get(token, "/user")
    user = %{name: user["name"], avatar: user["avatar_url"]}
    conn
    |> put_session(:current_user, user)
    |> put_session(:access_token, token.access_token)
    |> redirect(to: "/")
  end

  defp config do
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

  defp client do
    OAuth2.Client.new(config)
  end
end
