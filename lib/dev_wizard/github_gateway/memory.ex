defmodule DevWizard.GithubGateway.Memory do
  use ExActor.GenServer
  require Logger

  defstart start_link, do: initial_state(blank_slate)
  defcast stop, do: stop_server(:normal)

  def new(_) do
    start_link
  end

  defcall me(), state: state do
    reply(state.me)
  end

  defcall set_me(me), state: state do
    new_state(%{state | me: me})
    reply(:ok)
  end

  defcall add_member_to_org(org, username), state: state do
    new_membership = [{org, username} | state.org_memberships]

    %{state | org_memberships: new_membership} |> set_and_reply(:ok)
  end

  defcall member_of_org?(org, username), state: state do
    state.org_memberships
    |> Enum.member?({org, username})
    |> reply
  end

  defcall add_issue(org, repo, issue_info), state: state do
    new_issue_entry = {org, repo, issue_info}

    %{state | issues: [new_issue_entry | state.issues]} |> set_and_reply(:ok)
  end

  defcall filter_issues(org, repo, criteria), state: state do
    repo_filter = fn({an_org, a_repo, _}) ->
      {an_org, a_repo} == {org, repo}
    end

    state.issues
    |> Enum.filter(repo_filter)
    |> Enum.map(fn({_org, _repo, issue}) -> issue end)
    |> Enum.filter(fn(issue) ->
      case issue do
        ^criteria -> true
        _         -> false
      end
    end)
    |> Enum.reverse
    |> reply
  end

  defcall add_comment(org, repo, comment), state: state do
    new_comment = {org, repo, comment}

    %{state | comments: [new_comment | state.comments]} |> set_and_reply(:ok)
  end

  defcall comments(org, repo, issue_number), state: state do
    repo_filter = fn({an_org, a_repo, _}) ->
      {an_org, a_repo} == {org, repo}
    end

    state.comments
    |> Enum.filter(repo_filter)
    |> Enum.map(fn({_org, _repo, comment}) -> comment end)
    |> Enum.filter(fn(comment) -> comment.number == issue_number end)
    |> Enum.reverse
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
