defmodule DevWizard.IssueWorkflowTest do
  use ExUnit.Case
  alias DevWizard.IssueWorkflow
  alias DevWizard.GithubGateway.{Issue,Milestone}

  def fixture_data do
    {val, _} = Code.eval_file(Path.join(File.cwd!, ["test/", "fixtures/", "from-gateway.exs"]))

    for {k, v} <- val, into: %{}, do: {k, Enum.map(v, &Issue.to_struct/1)}
  end

  test "returns PRs assigned to requested user" do
    assigned = IssueWorkflow.pr_todo(fixture_data, "carols10cents")

    apangea_assigned = assigned["apangea"]

    assert Enum.count(apangea_assigned) == 1

    assignment = List.first(apangea_assigned)
    comments = assignment.comments
    first_comment = List.first(comments)

    assert Regex.run(~r/Code review assigned to dev\(s\): @carols10cents/, first_comment.body)
  end

  test "signifies if a user has signed off on this version of the PR" do
    assigned = IssueWorkflow.pr_todo(fixture_data, "carols10cents")

    apangea_assigned = assigned["apangea"]

    assert Enum.count(apangea_assigned) == 1

    assignment = List.first(apangea_assigned)
    comments = assignment.comments
    first_comment = List.first(comments)

    assert Regex.run(~r/Code review assigned to dev\(s\): @carols10cents/, first_comment.body)
  end

  test "marks issues that have been signed off" do

    assigned = IssueWorkflow.pr_todo(fixture_data, "marktfrey")["live_teaching"]
    assert Enum.count(assigned) == 1

    issue_with_lgtm = List.first(assigned)
    assert issue_with_lgtm.review_state == :signed_off
  end

  test "marks issues that have not been signed off" do
    assigned = IssueWorkflow.pr_todo(fixture_data, "seejee")["live_teaching"]
    assert Enum.count(assigned) == 1

    issue_with_lgtm = List.first(assigned)
    assert issue_with_lgtm.review_state == :not_signed_off
  end

  test "finds a PR milestone from linked issue" do
    storyboard = [
      %Issue{ number: 1000, milestone: %Milestone{ title: "Feature 1" } },
      %Issue{ number: 1001, milestone: %Milestone{ title: "Feature 2" } },
    ]

    pr =
      %Issue{ body: "Closes thinkthroughmath/storyboard#1001 here's some code" }
      |>IssueWorkflow.determine_milestone(storyboard)

    assert pr.milestone.title == "Feature 2"
  end

  test "handles when linked issue doesn't exist" do
    storyboard = []

    pr =
      %Issue{ body: "Closes thinkthroughmath/storyboard#1001 here's some code" }
      |> IssueWorkflow.determine_milestone(storyboard)

    assert pr.milestone == nil
  end

  test "handles when PR doesn't link an issue" do
    storyboard = [
      %Issue{ number: 1000, milestone: %Milestone{ title: "Feature 1" } },
    ]

    pr =
      %Issue{ body: "here's some code" }
      |> IssueWorkflow.determine_milestone(storyboard)

    assert pr.milestone == nil
  end
end
