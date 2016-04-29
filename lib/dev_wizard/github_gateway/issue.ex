defmodule DevWizard.GithubGateway.Issue do
  alias DevWizard.GithubGateway.User

  defstruct(
    assignee:       nil,
    body:           nil,
    closed_at:      nil,
    comments:       nil,
    comments_url:   nil,
    created_at:     nil,
    events_url:     nil,
    html_url:       nil,
    id:             nil,
    labels:         nil,
    labels_url:     nil,
    locked:         nil,
    milestone:      nil,
    number:         nil,
    pull_request:   nil,
    repository_url: nil,
    review_state:   nil,
    state:          nil,
    title:          nil,
    updated_at:     nil,
    url:            nil,
    user:           nil
  )

  use ExConstructor

  def to_struct(nil), do: nil

  def to_struct(values) do
    raw = new(values)
    %{ raw |
       :user     => User.to_struct(raw.user),
       :assignee => User.to_struct(raw.assignee)
     }
  end
end
