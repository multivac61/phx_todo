defmodule PhxTodoWeb.TodoHTML do
  use PhxTodoWeb, :html

  embed_templates "todo_html/*"

  @doc """
  Renders a todo form.
  """
  attr :changeset, Ecto.Changeset, required: true
  attr :action, :string, required: true

  def todo_form(assigns)
end
