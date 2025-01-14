defmodule PhxTodo.ToDosFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PhxTodo.ToDos` context.
  """

  @doc """
  Generate a to_do.
  """
  def to_do_fixture(attrs \\ %{}) do
    {:ok, to_do} =
      attrs
      |> Enum.into(%{
        done: true,
        name: "some name"
      })
      |> PhxTodo.ToDos.create_to_do()

    to_do
  end
end
