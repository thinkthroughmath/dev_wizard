defmodule DevWizard.IssueWorkflow do
  def pr_todo(repos_with_issues_with_comments, current_user_name) do
    Enum.map(repos_with_issues_with_comments, fn {repo, issues} ->
      comment_that_matches = fn(comment) ->
        match_info = Regex.run ~r/JSON_PAYLOAD([\s\S]*?)END_JSON_PAYLOAD/, comment["body"]
        if match_info do
          json_payload = Poison.decode!(Enum.at(match_info, 1))


          formatter = fn (str) ->
            str |> String.strip |> String.upcase
          end
          formatted_current_user_name = formatter.(current_user_name)

          Enum.find(json_payload["assignees"], fn(assignee) ->
             formatted_current_user_name == formatter.(assignee)
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
