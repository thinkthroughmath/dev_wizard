defmodule DevWizard.IssueWorkflowTest do
  use ExUnit.Case
  alias DevWizard.IssueWorkflow

  def fixture_data do
    {val, _} = Code.eval_file(Path.join(File.cwd!, ["test/", "fixtures/", "from-gateway.exs"]))
    val
  end

  test "returns PRs assigned to requested user" do
    assigned = IssueWorkflow.pr_todo(fixture_data, "carols10cents")

    apangea_assigned = assigned["apangea"]

    assert Enum.count(apangea_assigned) == 1

    assignment = List.first(apangea_assigned)
    comments = assignment["comments"]
    first_comment = List.first(comments)

    assert Regex.run(~r/Code review assigned to dev\(s\): @carols10cents/, first_comment["body"])
  end

  test "signifies if a user has signed off on this version of the PR" do
    assigned = IssueWorkflow.pr_todo(fixture_data, "carols10cents")

    apangea_assigned = assigned["apangea"]

    assert Enum.count(apangea_assigned) == 1

    assignment = List.first(apangea_assigned)
    comments = assignment["comments"]
    first_comment = List.first(comments)

    assert Regex.run(~r/Code review assigned to dev\(s\): @carols10cents/, first_comment["body"])
  end
end
