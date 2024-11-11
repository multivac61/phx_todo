defmodule PhxTodo.TodoLists do
  @moduledoc """
  The TodoLists context.
  """

  import Ecto.Query, warn: false
  alias PhxTodo.Repo

  alias PhxTodo.TodoLists.{List, Todo, SharedList}

  @doc """
  Returns the list of lists.

  ## Examples

      iex> list_lists()
      [%List{}, ...]

  """
  def list_lists do
    Repo.all(List)
  end

  @doc """
  Gets a single list.

  Raises `Ecto.NoResultsError` if the List does not exist.

  ## Examples

      iex> get_list!(123)
      %List{}

      iex> get_list!(456)
      ** (Ecto.NoResultsError)

  """
  def get_list!(id), do: Repo.get!(List, id)

  @doc """
  Creates a list.

  ## Examples

      iex> create_list(%{field: value})
      {:ok, %List{}}

      iex> create_list(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_list(attrs \\ %{}) do
    %List{}
    |> List.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a list.

  ## Examples

      iex> update_list(list, %{field: new_value})
      {:ok, %List{}}

      iex> update_list(list, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_list(%List{} = list, attrs) do
    list
    |> List.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a list.

  ## Examples

      iex> delete_list(list)
      {:ok, %List{}}

      iex> delete_list(list)
      {:error, %Ecto.Changeset{}}

  """
  def delete_list(%List{} = list) do
    Repo.delete(list)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking list changes.

  ## Examples

      iex> change_list(list)
      %Ecto.Changeset{data: %List{}}

  """
  def change_list(%List{} = list, attrs \\ %{}) do
    List.changeset(list, attrs)
  end

  alias PhxTodo.TodoLists.Todo

  @doc """
  Returns the list of todos.

  ## Examples

      iex> list_todos()
      [%Todo{}, ...]

  """
  def list_todos do
    Repo.all(Todo)
  end

  @doc """
  Gets a single todo.

  Raises `Ecto.NoResultsError` if the Todo does not exist.

  ## Examples

      iex> get_todo!(123)
      %Todo{}

      iex> get_todo!(456)
      ** (Ecto.NoResultsError)

  """
  def get_todo!(id), do: Repo.get!(Todo, id)

  @doc """
  Creates a todo.

  ## Examples

      iex> create_todo(%{field: value})
      {:ok, %Todo{}}

      iex> create_todo(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_todo(attrs \\ %{}) do
    %Todo{}
    |> Todo.changeset(attrs)
    |> Repo.insert()
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
  def share_list(list_id, user_id) do
    %SharedList{}
    |> SharedList.changeset(%{list_id: list_id, user_id: user_id})
    |> Repo.insert()
  end

  def unshare_list(list_id, user_id) do
    SharedList
    |> where(list_id: ^list_id, user_id: ^user_id)
    |> Repo.delete_all()
  end

  def get_shared_lists(user_id) do
    user_id
    |> SharedList.get_shared_lists()
    |> Repo.all()
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

  @doc """
  Updates a todo.

  ## Examples

      iex> update_todo(todo, %{field: new_value})
      {:ok, %Todo{}}

      iex> update_todo(todo, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_todo(%Todo{} = todo, attrs) do
    todo
    |> Todo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a todo.

  ## Examples

      iex> delete_todo(todo)
      {:ok, %Todo{}}

      iex> delete_todo(todo)
      {:error, %Ecto.Changeset{}}

  """
  def delete_todo(%Todo{} = todo) do
    Repo.delete(todo)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking todo changes.

  ## Examples

      iex> change_todo(todo)
      %Ecto.Changeset{data: %Todo{}}

  """
  def change_todo(%Todo{} = todo, attrs \\ %{}) do
    Todo.changeset(todo, attrs)
  end

  alias PhxTodo.TodoLists.SharedList

  @doc """
  Returns the list of shared_lists.

  ## Examples

      iex> list_shared_lists()
      [%SharedList{}, ...]

  """
  def list_shared_lists do
    Repo.all(SharedList)
  end

  @doc """
  Gets a single shared_list.

  Raises `Ecto.NoResultsError` if the Shared list does not exist.

  ## Examples

      iex> get_shared_list!(123)
      %SharedList{}

      iex> get_shared_list!(456)
      ** (Ecto.NoResultsError)

  """
  def get_shared_list!(id), do: Repo.get!(SharedList, id)

  @doc """
  Creates a shared_list.

  ## Examples

      iex> create_shared_list(%{field: value})
      {:ok, %SharedList{}}

      iex> create_shared_list(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_shared_list(attrs \\ %{}) do
    %SharedList{}
    |> SharedList.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a shared_list.

  ## Examples

      iex> update_shared_list(shared_list, %{field: new_value})
      {:ok, %SharedList{}}

      iex> update_shared_list(shared_list, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_shared_list(%SharedList{} = shared_list, attrs) do
    shared_list
    |> SharedList.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a shared_list.

  ## Examples

      iex> delete_shared_list(shared_list)
      {:ok, %SharedList{}}

      iex> delete_shared_list(shared_list)
      {:error, %Ecto.Changeset{}}

  """
  def delete_shared_list(%SharedList{} = shared_list) do
    Repo.delete(shared_list)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking shared_list changes.

  ## Examples

      iex> change_shared_list(shared_list)
      %Ecto.Changeset{data: %SharedList{}}

  """
  def change_shared_list(%SharedList{} = shared_list, attrs \\ %{}) do
    SharedList.changeset(shared_list, attrs)
  end
end
