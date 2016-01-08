defmodule DevWizard.GithubAuth do
  defstruct settings: %{}

  def new() do
    settings = %{
      site:          "https://api.github.com",
      authorize_url: "https://github.com/login/oauth/authorize",
      token_url:     "https://github.com/login/oauth/access_token",
      strategy:      OAuth2.Strategy.AuthCode, #default
      client_id:     Application.get_env(:dev_wizard, :github_settings)[:client_id],
      client_secret: Application.get_env(:dev_wizard, :github_settings)[:client_secret],
      redirect_uri:  Application.get_env(:dev_wizard, :github_settings)[:callback_uri]
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
