defmodule DevWizard.GithubGateway.User do
  defstruct(
    avatar_url: nil,
    events_url: nil,
    followers_url: nil,
    following_url: nil,
    gists_url: nil,
    gravatar_id: nil,
    html_url: nil,
    id: nil,
    login: nil,
    organizations_url: nil,
    received_events_url: nil,
    repos_url: nil,
    site_admin: nil,
    starred_url: nil,
    subscriptions_url: nil,
    type: nil,
    url: nil
  )

  use ExConstructor

  def to_struct(nil),    do: nil
  def to_struct(values), do: new(values)
end
