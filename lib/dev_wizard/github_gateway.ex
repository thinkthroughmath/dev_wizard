defmodule DevWizard.GithubGateway do
  defstruct(user: nil,
            tentacat_client: nil,
            settings: nil)

  def new(gh_access_token, user, settings) do
    tentacat = Tentacat.Client.new(%{access_token: gh_access_token})
    %DevWizard.GithubGateway{
      user:            user,
      tentacat_client: tentacat,
      settings:        settings
    }
  end

  def pulls_involving_you(gw) do
    Tentacat.Pulls.filter(gw.settings.organization,
                          gw.settings.default_repository,
                          %{involving: gw.user[:login]},
                          gw.tentacat_client)
  end

  defp oauth_client(gw) do
    config = [
      site:          "https: //api.github.com",
      authorize_url: "https: //github.com/login/oauth/authorize",
      token_url:     "https: //github.com/login/oauth/access_token",
      strategy:      OAuth2.Strategy.AuthCode, #default
      client_id:     gw.settings.gh_cilent_id,
      client_secret: gw.settings.gh_client_secret,
      redirect_uri:  gw.settings.gh_callback_uri
    ]

    OAuth2.Client.new(config)
  end
end
