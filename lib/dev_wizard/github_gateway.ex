defmodule DevWizard.GithubGateway do
  require Logger
  alias DevWizard.GithubGateway.Cache

  defstruct(user: nil,
            token: nil,
            settings: nil,
            tentacat_client: nil)

  def new(gh_access_token) do
    tentacat = Tentacat.Client.new(%{access_token: gh_access_token})
    settings = Application.get_env(:dev_wizard, :github_settings)

    user     = Tentacat.Users.me(tentacat)
    user     = %{name: user["name"], avatar: user["avatar_url"], login: user["login"]}

    %DevWizard.GithubGateway{
      token:           gh_access_token,
      user:            user,
      settings:        settings,
      tentacat_client: tentacat
    }
  end

  def member_of_organization?(gw), do: member_of_organization?(gw, gw.user[:login])
  def member_of_organization?(gw, username) do
    org = gw.settings[:organization]

    status =
      Cache.fetch_or_create(
        {:is_member, org, username},
        60 * 10, # 10 minutes
        fn ->
          {req_status, _} = Tentacat.Organizations.Members.member?(org,
                                                                   username,
                                                                   gw.tentacat_client)
          req_status
        end)

    case status do
      204 -> true
      _   -> false
    end
  end

  def involves(gw), do: involves(gw, gw.user[:login])
  def involves(gw, username) do
    repos_issues_and_comments(gw, %{involving: username})
  end

  def needs_code_review(gw) do
    repos_issues_and_comments(gw, %{labels: "Needs Code Review"})
  end

  defp repos_issues_and_comments(gw, filters) do
    org   = gw.settings[:organization]
    repos = gw.settings[:repositories]

    Enum.reduce(repos, %{},
      fn(repo, acc) ->
        issues = Tentacat.Issues.filter(org,
                                        repo,
                                        filters,
                                        gw.tentacat_client)

        issues_with_comments = Enum.map(issues,
          fn(issue) ->
            Map.put(issue,
                    "comments",
                    Tentacat.Issues.Comments.list(org,
                                                  repo,
                                                  issue["number"],
                                                  gw.tentacat_client))
          end)

        Logger.debug "GithubGateway/repo_issues_and_comments/issues_for repo: #{repo}, count: #{Enum.count issues_with_comments}, filters: #{inspect filters}"

        Map.put(acc,
                repo,
                issues_with_comments)
      end)
  end
end
