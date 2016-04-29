defmodule DevWizard.GithubGateway.Comment do
  alias DevWizard.GithubGateway.User

  defstruct(body: nil,
            created_at: nil,
            html_url: nil,
            id: nil,
            updated_at: nil,
            url: nil,
            user: nil
  )

  use ExConstructor

  def to_struct(nil), do: nil

  def to_struct(values) do
    raw = new(values)

    %{ raw |
       :user     => User.to_struct(raw.user)
     }
  end
end
