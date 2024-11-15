defmodule PhxTodo.Todos do
  import Ecto.Query
  alias PhxTodo.Repo
  alias PhxTodo.Todos.Todo

  def list_todos(user) do
    Todo
    |> where(user_id: ^user.id)
    |> order_by([t], desc: t.inserted_at)
    |> Repo.all()
  end

  def get_todo!(id, user_id) do
    Todo
    |> where(user_id: ^user_id)
    |> Repo.get!(id)
  end

  def create_todo(attrs \\ %{}) do
    %Todo{}
    |> Todo.changeset(attrs)
    |> Repo.insert()
  end

  def update_todo(%Todo{} = todo, attrs) do
    todo
    |> Todo.changeset(attrs)
    |> Repo.update()
  end

  def delete_todo(%Todo{} = todo) do
    Repo.delete(todo)
  end

  def change_todo(%Todo{} = todo, attrs \\ %{}) do
    Todo.changeset(todo, attrs)
  end

  def toggle_todo(%Todo{} = todo) do
    update_todo(todo, %{completed: !todo.completed})
  end
end
