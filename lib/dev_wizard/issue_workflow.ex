defmodule DevWizard.IssueWorkflow do

  @json_payload_regex ~r/JSON_PAYLOAD([\s\S]*?)END_JSON_PAYLOAD/

  def pr_todo(repos_with_issues_with_comments, current_user_name) do
    Enum.map(repos_with_issues_with_comments, fn {repo, issues} ->
      comment_that_matches_current_user = fn (comment)->
        comment_has_assigned_user?(comment,
                                  current_user_name)
      end

      issue_has_assignment? = fn(issue)->
        Enum.find(issue["comments"],
                  comment_that_matches_current_user)
      end

      assigned_prs = Enum.filter(issues, issue_has_assignment?)

      {repo, assigned_prs}
    end) |> Enum.into(%{})
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
    match_info = Regex.run @json_payload_regex, comment["body"]

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
