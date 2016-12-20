defmodule DevWizard.IssueWorkflow do

  alias DevWizard.GithubGateway.Issue

  def pr_todo(repos_with_issues_with_reviewers, user) do
    repos_with_issues_with_reviewers
    |> Enum.map(fn {repo, issues} ->
      {repo, assigned_prs_from_issues(issues, user)}
    end)
    |> Enum.into(%{})
  end

  def determine_milestone(issue = %Issue{}, storyboard_issues) do
    linked_issue_number = Issue.linked_issue_number(issue)

    linked_issue =
      linked_issue_number &&
      Enum.find(storyboard_issues, &(&1.number == linked_issue_number))

    if linked_issue do
      %{issue | milestone: linked_issue.milestone }
    else
      issue
    end
  end

  def determine_milestone(repos_with_issues, storyboard_issues) do
    Enum.reduce(repos_with_issues, %{}, fn({repo, issues}, acc) ->
      issues = Enum.map(issues, &(determine_milestone(&1, storyboard_issues)))
      Map.put(acc, repo, issues)
    end)
  end

  defp assigned_prs_from_issues(issues, user) do
    issues
    |> Enum.filter(fn(issue) ->
      issue_has_assignment?(issue, user) || issue_has_reviewer?(issue, user)
    end)
    |> Enum.map(fn(issue) ->
      state = determine_review_state(issue, user)
      %{ issue | :review_state => state }
    end)
  end

  defp issue_has_assignment?(issue, user) do
    Enum.find(issue.assignees, fn(assignee) ->
      assignee.login == user
    end)
  end

  defp issue_has_reviewer?(issue, user) do
    Enum.find(issue.reviewers, fn(reviewer) ->
      reviewer.login == user
    end)
  end

  defp determine_review_state(issue, user) do
    found =
      issue
      |> Issue.merged_reviews
      |> Enum.find(fn(review) ->
        review.user.login == user
      end)

    case found && found.state do
      :approved          -> :signed_off
      :changes_requested -> :changes_requested
      _                  -> :not_signed_off
    end
  end
end
