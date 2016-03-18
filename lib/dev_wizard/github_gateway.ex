defmodule DevWizard.GithubGateway do
  require Logger
  alias DevWizard.GithubGateway.Cache

  @github_api Application.get_env(:dev_wizard, :github_api)

  defstruct(user: nil,
            token: nil,
            settings: nil,
            github_client: nil)

  def new(gh_access_token) do
    github   = @github_api.new(%{access_token: gh_access_token})
    settings = Application.get_env(:dev_wizard, :github_settings)

    user     = @github_api.me(github)
    user     = %{name: user["name"], avatar: user["avatar_url"], login: user["login"]}

    %DevWizard.GithubGateway{
      token:           gh_access_token,
      user:            user,
      settings:        settings,
      github_client: github
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
          {req_status, _} = @github_api.member_of_org?(gw.github_client,
                                                       org,
                                                       username)
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

        issues = Cache.fetch_or_create(
          {:issues, repo},
          60 * 10, # 10 minutes
          fn ->
            @github_api.filter(
              gw.github_client,
              org,
              repo,
              filters
            )
          end)

        issues_with_comments = Enum.map(issues,
          fn(issue) ->
            comments =
              Cache.fetch_or_create(
                {:issue_comments, repo, issue["number"]},
                60 * 10, # 10 minutes
                fn ->
                  @github_api.list(
                    gw.github_client,
                    org,
                    repo,
                    issue["number"]
                  )
                end)

            Map.put(issue,
                    "comments",
                    comments)
          end)

        Logger.debug "GithubGateway/repo_issues_and_comments/issues_for repo: #{repo}, count: #{Enum.count issues_with_comments}, filters: #{inspect filters}"

        Map.put(acc,
                repo,
                issues_with_comments)
      end)
  end
end
