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

  def is_user_member_of_organization(gh_access_token, organization) do
    client = Tentacat.Client.new(%{access_token: gh_access_token})

    user = Tentacat.Users.me(client)
    user = %{name: user["name"], avatar: user["avatar_url"], login: user["login"]}

    is_member = Tentacat.Organizations.Members.member?(organization, user[:login], client)
    case is_member do
      {204, _} -> true
            _  -> false
    end
  end

  def pulls_involving_you(gw) do
    Tentacat.Pulls.filter(gw.settings.organization,
                          gw.settings.default_repository,
                          %{involving: gw.user[:login]},
                          gw.tentacat_client)
  end
end
