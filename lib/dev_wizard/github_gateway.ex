defmodule DevWizard.GithubGateway do
  require Logger
  alias DevWizard.GithubGateway.Cache
  alias DevWizard.GithubGateway.User
  alias DevWizard.GithubGateway.Review

  @github_api Application.get_env(:dev_wizard, :github_api)
  @cache_time 60 * 10 # 10 minutes

  defstruct(user: nil,
            token: nil,
            settings: nil,
            github_client: nil)

  def new(gh_access_token) do
    github   = @github_api.new(gh_access_token)
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

    Cache.fetch_or_create(
      {:is_member, org, username},
      @cache_time,
      fn ->
        @github_api.member_of_org?(
          gw.github_client,
          org,
          username
        )
      end)
  end

  def involves(gw), do: involves(gw, gw.user[:login])
  def involves(gw, username) do
    repos_issues_and_reviewers(gw, %{involving: username})
  end

  def needs_code_review(gw) do
    repos_issues_and_reviewers(gw, %{labels: "Needs Code Review"})
  end

  def needs_qa(gw) do
    repos_issues_and_reviewers(gw, %{labels: "Needs QA"})
  end

  def needs_release_notes(gw) do
    repos_issues_and_reviewers(gw, %{labels: "Needs Release Notes"})
  end

  def storyboard_issues(gw) do
    org  = gw.settings[:organization]
    repo = gw.settings[:storyboard_repo]
    issues(gw, org, repo, %{state: "open"})
  end

  defp repos_issues_and_reviewers(gw, filters) do
    org   = gw.settings[:organization]
    repos = gw.settings[:repositories]

    Enum.reduce(repos, %{}, fn(repo, acc) ->
      issues = issues_with_reviewers(gw, org, repo, filters)
      Logger.debug "GithubGateway/repo_issues_and_reviewers/issues_for repo: #{repo}, count: #{Enum.count issues}, filters: #{inspect filters}"
      Map.put(acc, repo, issues)
    end)
  end

  defp issues_with_reviewers(gw, org, repo, filters) do
    issues = issues(gw, org, repo, filters)

    case issues do
      {404, _} ->
        []
      issues   ->
        Enum.map(issues, fn(issue) ->
          %{ issue |
             :reviewers => reviewers(gw, org, repo, issue),
             :reviews => reviews(gw, org, repo, issue)
           }
        end)
    end
  end

  defp issues(gw, org, repo, filters) do
    Cache.fetch_or_create(
      {:issues, repo, filters},
      @cache_time,
      fn ->
        @github_api.filter_issues(
          gw.github_client,
          org,
          repo,
          filters
        )
      end)
  end

  defp reviewers(gw, org, repo, issue) do
    reviewers = Cache.fetch_or_create(
      {:issue_reviewers, repo, issue.number},
      @cache_time,
      fn ->
        @github_api.requested_reviewers(
          gw.github_client,
          org,
          repo,
          issue.number
        )
      end)

    reviewers
    |> Enum.map(&User.to_struct/1)
  end

  defp reviews(gw, org, repo, issue) do
    reviews = Cache.fetch_or_create(
      {:issue_reviews, repo, issue.number},
      @cache_time,
      fn ->
        @github_api.reviews(
          gw.github_client,
          org,
          repo,
          issue.number
        )
      end)

    reviews
    |> Enum.map(&Review.to_struct/1)
  end

end
