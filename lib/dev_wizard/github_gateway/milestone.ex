defmodule DevWizard.GithubGateway.Milestone do

  defstruct(
    title:       nil,
    number:      nil,
    description: nil,
    id:          nil,
  )

  use ExConstructor

  def to_struct(nil), do: nil

  def to_struct(values) do
    new(values)
  end
end
