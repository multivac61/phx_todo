defmodule PhxTodo.TodoLists.Todo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field :title, :string
    field :completed, :boolean, default: false
    belongs_to :list, PhxTodo.TodoLists.List
    belongs_to :user, PhxTodo.Accounts.User

    timestamps()
  end

  def changeset(todo, attrs) do
    todo
    |> cast(attrs, [:title, :completed, :list_id, :user_id])
    |> validate_required([:title, :list_id, :user_id])
    |> foreign_key_constraint(:list_id)
    |> foreign_key_constraint(:user_id)
  end
end
