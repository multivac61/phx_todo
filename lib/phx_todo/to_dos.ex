defmodule PhxTodo.ToDos do
  @moduledoc """
  The ToDos context.
  """

  import Ecto.Query, warn: false
  alias PhxTodo.Repo

  alias PhxTodo.ToDos.ToDo

  @doc """
  Returns the list of todos.

  ## Examples

      iex> list_todos()
      [%ToDo{}, ...]

  """
  def list_todos do
    Repo.all(from t in ToDo, order_by: [asc: t.updated_at])
  end

  @doc """
  Gets a single to_do.

  Raises `Ecto.NoResultsError` if the To do does not exist.

  ## Examples

      iex> get_to_do!(123)
      %ToDo{}

      iex> get_to_do!(456)
      ** (Ecto.NoResultsError)

  """
  def get_to_do!(id), do: Repo.get!(ToDo, id)

  @doc """
  Creates a to_do.

  ## Examples

      iex> create_to_do(%{field: value})
      {:ok, %ToDo{}}

      iex> create_to_do(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_to_do(attrs \\ %{}) do
    %ToDo{}
    |> ToDo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a to_do.

  ## Examples

      iex> update_to_do(to_do, %{field: new_value})
      {:ok, %ToDo{}}

      iex> update_to_do(to_do, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_to_do(%ToDo{} = to_do, attrs) do
    to_do
    |> ToDo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a to_do.

  ## Examples

      iex> delete_to_do(to_do)
      {:ok, %ToDo{}}

      iex> delete_to_do(to_do)
      {:error, %Ecto.Changeset{}}

  """
  def delete_to_do(%ToDo{} = to_do) do
    Repo.delete(to_do)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking to_do changes.

  ## Examples

      iex> change_to_do(to_do)
      %Ecto.Changeset{data: %ToDo{}}

  """
  def change_to_do(%ToDo{} = to_do, attrs \\ %{}) do
    ToDo.changeset(to_do, attrs)
  end
end
