defmodule PhxTodo.Repo.Migrations.CreateTodos do
  use Ecto.Migration

  def change do
    create table(:todos) do
      add :title, :string
      add :completed, :boolean, default: false, null: false
      add :list_id, references(:lists, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:todos, [:list_id])
    create index(:todos, [:user_id])
  end
end
