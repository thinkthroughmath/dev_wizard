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
    reply(Enum.filter(state.issues, filter))
  end

  defcall reset() do
    set_and_reply(blank_slate, :ok)
  end

  def member_of_org?(client, org, username) do
    {req_status, _} = Tentacat.Organizations.Members.member?(org, username, client.tentacat)

    case req_status do
      204 -> true
      _   -> false
    end
  end

  def filter_issues(client, org, repo, filters) do
    Tentacat.Issues.filter(org, repo, filters, client.tentacat)
  end

  def comments(client, org, repo, issue)  do
    Tentacat.Issues.Comments.list(org, repo, issue, client.tentacat)
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
