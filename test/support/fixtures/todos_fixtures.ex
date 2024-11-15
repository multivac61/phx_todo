# test/support/fixtures/todos_fixtures.ex
defmodule PhxTodo.TodosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PhxTodo.Todos` context.
  """

  @doc """
  Generate a todo.
  """
  def todo_fixture(attrs \\ %{}) do
    {:ok, todo} =
      attrs
      |> Enum.into(%{
        completed: false,
        title: "some title",
        user_id: attrs[:user_id] || user_fixture().id
      })
      |> PhxTodo.Todos.create_todo()

    todo
  end

  defp user_fixture do
    PhxTodo.AccountsFixtures.user_fixture()
  end
end
