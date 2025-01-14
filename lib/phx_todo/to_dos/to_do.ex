defmodule PhxTodo.ToDos.ToDo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "todos" do
    field :name, :string
    field :done, :boolean, default: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(to_do, attrs) do
    to_do
    |> cast(attrs, [:name, :done])
    |> validate_required([:name, :done])
  end
end
