defmodule PhxTodo.TodoLists do
  import Ecto.Query
  alias PhxTodo.Repo
  alias PhxTodo.TodoLists.{List, Todo, SharedList}

  def get_user_lists(user_id) do
    List
    |> where(user_id: ^user_id)
    # Optionally preload todos
    |> preload(:todos)
    |> Repo.all()
  end

  def get_list!(id), do: Repo.get!(List, id)

  def create_list(attrs \\ %{}) do
    %List{}
    |> List.changeset(attrs)
    |> Repo.insert()
  end

  def update_list(%List{} = list, attrs) do
    list
    |> List.changeset(attrs)
    |> Repo.update()
  end

  def delete_list(%List{} = list) do
    Repo.delete(list)
  end

  def change_list(%List{} = list, attrs \\ %{}) do
    List.changeset(list, attrs)
  end

  # Todo management
  def get_todo!(id), do: Repo.get!(Todo, id)

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

  def get_todos_for_list(list_id) do
    Todo
    |> where(list_id: ^list_id)
    |> order_by(asc: :inserted_at)
    |> Repo.all()
  end

  # Sharing functionality
  def create_shared_list(attrs \\ %{}) do
    %SharedList{}
    |> SharedList.changeset(attrs)
    |> Repo.insert()
  end

  def delete_shared_list(%SharedList{} = shared_list) do
    Repo.delete(shared_list)
  end

  def get_shared_list!(id), do: Repo.get!(SharedList, id)

  def get_shared_lists(user_id) do
    SharedList
    |> where(user_id: ^user_id)
    |> preload(:list)
    |> Repo.all()
  end

  def share_list(list_id, user_id) do
    create_shared_list(%{
      list_id: list_id,
      user_id: user_id
    })
  end

  def unshare_list(list_id, user_id) do
    SharedList
    |> where(list_id: ^list_id, user_id: ^user_id)
    |> Repo.delete_all()
  end

  def can_access_list?(list_id, user_id) do
    List
    |> where(id: ^list_id)
    |> where(
      [l],
      l.user_id == ^user_id or
        fragment(
          "EXISTS (SELECT 1 FROM shared_lists WHERE list_id = ? AND user_id = ?)",
          l.id,
          ^user_id
        )
    )
    |> Repo.exists?()
  end
end
