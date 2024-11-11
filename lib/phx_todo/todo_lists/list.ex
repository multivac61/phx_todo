defmodule PhxTodo.TodoLists.List do
  use Ecto.Schema
  import Ecto.Changeset

  schema "lists" do
    field :title, :string
    belongs_to :user, PhxTodo.Accounts.User
    has_many :todos, PhxTodo.TodoLists.Todo
    has_many :shared_lists, PhxTodo.TodoLists.SharedList
    has_many :shared_with_users, through: [:shared_lists, :user]

    timestamps()
  end

  def changeset(list, attrs) do
    list
    |> cast(attrs, [:title, :user_id])
    |> validate_required([:title, :user_id])
    |> foreign_key_constraint(:user_id)
  end
end
