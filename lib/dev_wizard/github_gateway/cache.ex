defmodule DevWizard.GithubGateway.Cache do
  use ExActor.GenServer, export: __MODULE__
  use Timex
  require Logger

  defstart start_link, do: initial_state(%{})

  defcall fetch_or_create(key, time_to_keep, creator), state: state do
    if Map.has_key?(state, key) do
      Logger.debug "Cache  hit: #{inspect key}"
      results = Map.get(state, key)

      earliest_to_keep = Date.now(:secs) - time_to_keep
      if results[:timestamp] < earliest_to_keep do
        Logger.debug "Cache entry expired: #{inspect key}"
        {new_cache, results} = set_cache_with_results(state, key, creator)
        set_and_reply(new_cache, results[:value])
      else
        reply(results[:value])
      end
    else
      Logger.debug "Cache miss: #{inspect key}"
      {new_cache, results} = set_cache_with_results(state, key, creator)
      set_and_reply(new_cache, results[:value])
    end
  end

  defp set_cache_with_results(state, key, creator) do
    creator_results = creator.()
    time = Date.now(:secs)
    results = %{:timestamp => time, :value => creator_results}
    new_cache = Map.put(state, key, results)
    {new_cache, results}
  end
end
