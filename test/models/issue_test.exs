defmodule DevWizard.IssueTest do
  use ExUnit.Case
  alias DevWizard.GithubGateway.Issue

  test "extracts linked issue with connects" do
    number =
      %Issue{body: "connects thinkthroughmath/storyboard#1000 asdasd" }
      |> Issue.linked_issue_number

    assert number == 1000
  end

  test "extracts linked issue with connects to" do
    number =
      %Issue{body: "connects to thinkthroughmath/storyboard#1000 asdasd" }
      |> Issue.linked_issue_number

    assert number == 1000
  end

  test "extracts linked issue with connected to" do
    number =
      %Issue{body: "connected to thinkthroughmath/storyboard#1000 asdasd" }
      |> Issue.linked_issue_number

    assert number == 1000
  end

  test "extracts linked issue with closes" do
    number =
      %Issue{body: "closes thinkthroughmath/storyboard#1000 asdasd" }
      |> Issue.linked_issue_number

    assert number == 1000
  end

  test "extracts linked issue with fixes" do
    number =
      %Issue{body: "fixes    thinkthroughmath/storyboard#1000 asdasd" }
      |> Issue.linked_issue_number

    assert number == 1000
  end

  test "extracts linked issue with full github url" do
    number =
      %Issue{body: "closes https://github.com/thinkthroughmath/storyboard/issues/1000 asdasd" }
      |> Issue.linked_issue_number

    assert number == 1000
  end

  test "doesn't find a linked issue later in the description" do
    number =
      %Issue{body: "closes some stuff here is some other stuff thinkthroughmath/storyboard#9999 asdasd" }
      |> Issue.linked_issue_number

    assert number == nil
  end

  test "doesn't find a url later in the description" do
    number =
      %Issue{body: "closes some stuff here is some other stuff https://github.com/thinkthroughmath/storyboard/issues/9999 asdasd" }
      |> Issue.linked_issue_number

    assert number == nil
  end
end
