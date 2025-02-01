defmodule PhxTodoWeb.LiveHelpers do
  def last_update(datetime), do: datetime |> Timex.format("{relative}", :relative) |> elem(1)
end
