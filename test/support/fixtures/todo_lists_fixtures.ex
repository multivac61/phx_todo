defmodule PhxTodo.TodoListsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `PhxTodo.TodoLists` context.
  """

  @doc """
  Generate a list.
  """
  def list_fixture(attrs \\ %{}) do
    {:ok, list} =
      attrs
      |> Enum.into(%{
        title: "some title"
      })
      |> PhxTodo.TodoLists.create_list()

    list
  end

  @doc """
  Generate a todo.
  """
  def todo_fixture(attrs \\ %{}) do
    {:ok, todo} =
      attrs
      |> Enum.into(%{
        completed: true,
        title: "some title"
      })
      |> PhxTodo.TodoLists.create_todo()

    todo
  end

  @doc """
  Generate a shared_list.
  """
  def shared_list_fixture(attrs \\ %{}) do
    {:ok, shared_list} =
      attrs
      |> Enum.into(%{})
      |> PhxTodo.TodoLists.create_shared_list()

    shared_list
  end
end
