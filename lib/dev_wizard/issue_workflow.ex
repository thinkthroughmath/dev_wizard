defmodule DevWizard.IssueWorkflow do
  @json_payload_regex ~r/JSON_PAYLOAD([\s\S]*?)END_JSON_PAYLOAD/

  def pr_todo(repos_with_issues_with_comments, user) do
    repos_with_issues_with_comments
    |> Enum.map(fn {repo, issues} ->
      {repo, assigned_prs_for_repo(repo, issues, user)}
    end)
    |> Enum.into(%{})
  end

  defp assigned_prs_for_repo(repo, issues, user) do
    comment_that_matches_current_user = fn (comment)->
      comment_has_assigned_user?(comment, user)
    end

    issue_has_assignment? = fn(issue)->
      Enum.find(
        issue.comments,
        comment_that_matches_current_user
      )
    end

    issues
    |> Enum.filter(issue_has_assignment?)
    |> Enum.map(fn(issue) ->
      state = determine_review_state(issue, user)
      %{ issue | :review_state => state }
    end)
  end

  defp determine_review_state(issue, user) do
    lgtms = lgtm_comments(issue, user)

    if Enum.any?(lgtms) do
      :signed_off
    else
      :not_signed_off
    end
  end

  defp lgtm_comments(issue, user) do
    issue.comments
    |> Enum.filter(fn(comment) ->
      Regex.run(~r/LGTM/, comment.body) &&
        comment.user.login == user
    end)
  end

  defp comment_has_assigned_user?(comment, assigned_username) do
    assignment_data = parsed_json_payload(comment)

    case assignment_data do
      {:some, data} ->
        Enum.find(data["assignees"], fn(assignee) ->
          normalize_username(assigned_username) ==
            normalize_username(assignee)
        end)
      _ -> false
    end
  end

  defp parsed_json_payload(comment) do
    match_info = Regex.run @json_payload_regex, comment.body

    if match_info do
      json_payload = Poison.decode!(Enum.at(match_info, 1))
      {:some, json_payload}
    else
      {:none, "no json payload found"}
    end
  end

  defp normalize_username(name) do
    name |> String.strip |> String.upcase
  end
end
