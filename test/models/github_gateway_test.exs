defmodule DevWizard.GithubGatewayTest do
  use ExUnit.Case
  alias DevWizard.GithubGateway.Cache

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
