defmodule DevWizard.GithubGateway do
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

  def is_user_member_of_organization(gw) do
    org = gw.settings[:organization]

    is_member = Tentacat.Organizations.Members.member?(org, gw.user[:login], gw.tentacat_client)

    case is_member do
      {204, _} -> true
            _  -> false
    end
  end

  def pulls_involving_you(gw) do
    org   = gw.settings[:organization]
    repos = gw.settings[:repositories]

    Enum.reduce(repos, %{},
      fn(repo, acc) ->
        pulls = Tentacat.Pulls.filter(org,
                                      repo,
                                      %{involving: gw.user[:login]},
                                      gw.tentacat_client)
        Map.put(acc,
                repo,
                pulls)
    end)
  end

  def pr_todo(gw) do
    org   = gw.settings[:organization]
    repos = gw.settings[:repositories]

    results = Enum.reduce(repos, %{},
      fn(repo, acc) ->
        issues = Tentacat.Issues.filter(org,
                                        repo,
                                        %{labels: "Needs Code Review"},
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

        Map.put(acc,
                repo,
                issues_with_comments)
      end)

    the_pure_bits(results, gw.user[:login])
  end

  def the_pure_bits(repos_with_issues_with_comments, current_user_name) do
    Enum.map(repos_with_issues_with_comments, fn {repo, issues} ->
      comment_that_matches = fn(comment) ->
        match_info = Regex.run ~r/JSON_PAYLOAD([\s\S]*?)END_JSON_PAYLOAD/, comment["body"]
        if match_info do
          json_payload = Poison.decode!(Enum.at(match_info, 1))

          Enum.find(json_payload["assignees"], fn(assignee) ->
            current_user_name == assignee
          end)
        end
      end

      find_issue_with_assignment = fn(issue)->
        Enum.find issue["comments"], comment_that_matches
      end

      {repo, Enum.filter(issues, find_issue_with_assignment)}
    end) |> Enum.into(%{})
  end
end
