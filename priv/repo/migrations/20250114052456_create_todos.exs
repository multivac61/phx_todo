defmodule PhxTodo.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :name, :string
      add :done, :boolean, default: false, null: false

      timestamps(type: :utc_datetime)
    end
  end
end
