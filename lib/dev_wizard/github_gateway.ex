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
end
