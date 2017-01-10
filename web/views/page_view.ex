defmodule DevWizard.PageView do
  alias DevWizard.GithubGateway.Issue
  use DevWizard.Web, :view
  use Timex

  def days_since(date) do
    {:ok, date} = Timex.parse(date, "{ISOz}")

    days = Timex.DateTime.diff(date, Timex.DateTime.now, :days)

    case days do
      0    -> "Today"
      1    -> "Yesterday"
      days -> "#{days} days ago"
    end
  end

  def assignee_title(phase) do
    case phase do
      :needs_code_review -> "Reviewers"
      _ -> "Assignees"
    end
  end

  def reviews(issue) do
    Issue.merged_reviews(issue)
  end
end
