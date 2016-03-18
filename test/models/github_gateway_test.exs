defmodule DevWizard.GithubGatewayTest do
  defmodule Gateway do
    use ExUnit.Case
    alias DevWizard.GithubGateway.Memory
    setup do
      {:ok, pid} = Memory.start_link

      on_exit fn ->
        Memory.stop(pid)
      end

      {:ok, pid: pid}
    end

    test "filtering issues", %{pid: pid} do
      :ok = pid |> Memory.add_issue("thinkthroughmath", "apangea", %{something: "matching"})
      :ok = pid |> Memory.add_issue("thinkthroughmath", "apangea", %{something: "else"})

      matches = pid |> Memory.filter_issues(
        "thinkthroughmath",
        "apangea",
        %{something: "matching"}
      )

      assert matches == [
        %{something: "matching"},
      ]
    end

    test "member of org" , %{pid: pid} do
      :ok = pid |> Memory.add_member_to_org("thinkthroughmath", "joelo")

      is_member   = pid |> Memory.member_of_org?("thinkthroughmath", "joelo")
      isnt_member = pid |> Memory.member_of_org?("thinkthroughmath", "steve")

      assert is_member == true
      assert isnt_member == false
    end

  end

  defmodule Cache do
    alias DevWizard.GithubGateway.Cache
    use ExUnit.Case
    setup do
      Cache.empty
    end

    test "It should return the result of calling the creator function" do
      assert "foo" == Cache.fetch_or_create("somethin", 1234, fn -> "foo" end)
    end

    test "after caching a previous value, it should return that value" do
      Cache.fetch_or_create("somethin", 1234, fn -> "foo" end)
      cached_val = Cache.fetch_or_create("somethin", 999999, fn -> "no foo" end)
      assert "foo" == cached_val
    end

    test "it uses the new value if the existing value is expired" do
      Cache.fetch_or_create("somethin", 1234, fn -> "foo" end)
      cached_val = Cache.fetch_or_create("somethin", -9999, fn -> "no foo" end)
      assert "no foo" == cached_val
    end
  end
end
