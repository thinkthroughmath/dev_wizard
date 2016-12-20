defmodule DevWizard.GithubGateway.Review do
  alias DevWizard.GithubGateway.User

  defstruct(
    id:        nil,
    user:      nil,
    body:      nil,
    commit_id: nil,
    state:     nil,
  )

  use ExConstructor

  def to_struct(nil), do: nil

  def to_struct(values) do
    raw = new(values)

    %{ raw |
       :user => User.to_struct(raw.user),
       :state => parse_state(raw.state)
    }
  end

  def parse_state(state) do
    case state do
      "APPROVED"          -> :approved
      "DISMISSED"         -> :dismissed
      "CHANGES_REQUESTED" -> :changes_requested
      _                   -> :pending
    end
  end
end
