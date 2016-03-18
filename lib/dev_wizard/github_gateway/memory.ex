defmodule DevWizard.GithubGateway.Memory do
  use ExActor.GenServer
  require Logger

  defstart start_link, do: initial_state(blank_slate)

  def new(_) do
    start_link
  end

  defcall me(), state: state do
    reply(state.me)
  end

  defcast set_me(me), state: state do
    new_state(%{state | me: me})
  end

  defcast add_member_to_org(org, username), state: state do
    new_membership = [[org, username] | state.org_memberships]
    new_state(%{state | org_memberships: new_membership})
  end

  defcall member_of_org?(org, username), state: state do
    reply(Enum.member?(state.org_memberships, [org, username]))
  end

  defcast add_issue(org, repo, issue_info), state: state do
    new_issue_entry = {org, repo, issue_info}
    new_state(%{state | issues: [new_issue_entry | state.issues]})
  end

  defcall filter_issues(org, repo, _filters), state: state do
    filter = fn({an_org, a_repo, _}) ->
      {an_org, a_repo} == {org, repo}
    end

    state.issues
    |> Enum.filter(filter)
    |> reply
  end

  defcall reset() do
    set_and_reply(blank_slate, :ok)
  end

  defp blank_slate do
    %{
      me: nil,
      org_memberships: [],
      issues: [],
      comments: [],
    }
  end
end
