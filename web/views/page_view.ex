defmodule DevWizard.PageView do
  use DevWizard.Web, :view

  def review_state(issue) do
    case issue["review_state"] do
      :not_signed_off -> "Needs Review!"
      :signed_off     -> "Signed Off"
      _               -> "?"
    end
  end
end
