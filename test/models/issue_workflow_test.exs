defmodule DevWizard.IssueWorkflowTest do
  use ExUnit.Case
  alias DevWizard.IssueWorkflow
  alias DevWizard.GithubGateway.{Issue,Milestone,Comment,User}

  def fixture_data do
    {val, _} = Code.eval_file(Path.join(File.cwd!, ["test/", "fixtures/", "from-gateway.exs"]))

    for {k, v} <- val, into: %{}, do: {k, Enum.map(v, &Issue.to_struct/1)}
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
