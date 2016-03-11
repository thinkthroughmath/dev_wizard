defmodule DevWizard.GithubGatewayTest do
  defmodule Gateway do
    use ExUnit.Case
    setup do
      :ok
    end

    test "hi" do
      DevWizard.GithubGateway.Memory.start_link
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
