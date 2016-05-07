defmodule DevWizard.PageView do
  use DevWizard.Web, :view
  use Timex

  def days_since(date) do
    {:ok, date} = Timex.parse(date, "{ISOz}")

    days = Timex.DateTime.diff(date, Timex.DateTime.now, :days)

    case days do
      0    -> "Today"
      1    -> "Yesterday"
      days -> "#{days} days ago"
    end
  end
end
