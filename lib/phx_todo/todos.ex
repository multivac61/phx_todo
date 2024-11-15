defmodule PhxTodo.Todos do
  import Ecto.Query
  alias PhxTodo.Repo
  alias PhxTodo.Todos.Todo

  def list_todos(user, filters \\ %{}, sort \\ %{by: :inserted_at, order: :desc}) do
    Todo
    |> where(user_id: ^user.id)
    |> filter_by_search(filters)
    |> filter_by_status(filters)
    |> apply_sort(sort)
    |> Repo.all()
  end

  defp filter_by_search(query, %{search: search}) when is_binary(search) and search != "" do
    query |> where([t], ilike(t.title, ^"%#{search}%"))
  end

  defp filter_by_search(query, _), do: query

  defp filter_by_status(query, %{status: "completed"}),
    do: query |> where([t], t.completed == true)

  defp filter_by_status(query, %{status: "pending"}) do
    query |> where([t], t.completed == false)
  end

  defp filter_by_status(query, _), do: query

  defp apply_sort(query, %{by: :title, order: order}) do
    query |> order_by([{^order, :title}])
  end

  defp apply_sort(query, %{by: :completed, order: order}) do
    query |> order_by([{^order, :completed}, {:desc, :inserted_at}])
  end

  defp apply_sort(query, %{by: :inserted_at, order: order}) do
    query |> order_by([{^order, :inserted_at}])
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
