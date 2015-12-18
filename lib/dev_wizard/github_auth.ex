defmodule DevWizard.GithubAuth do
  defstruct settings: %{}

  def new(settings) do
    settings = %{
      site:          "https://api.github.com",
      authorize_url: "https://github.com/login/oauth/authorize",
      token_url:     "https://github.com/login/oauth/access_token",
      strategy:      OAuth2.Strategy.AuthCode, #default
      client_id:     settings.gh_client_id,
      client_secret: settings.gh_client_secret,
      redirect_uri:  settings.gh_callback_uri
    }
    %DevWizard.GithubAuth{
      settings: settings
    }
  end

  def authorize_url(auth) do
    perms = "user,public_repo,read:org,repo"
    client(auth)
      |> OAuth2.Client.put_param(:scope, perms)
      |> OAuth2.Client.authorize_url!([])
  end

  def get_token_from_callback_code(auth, code) do
    response = client(auth)
    |> OAuth2.Client.put_header("Accept", "application/json")
    |> OAuth2.Client.get_token!(code: code)
    response.access_token
  end

  defp client(auth) do
    OAuth2.Client.new(auth.settings)
  end
end
