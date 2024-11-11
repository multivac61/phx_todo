defmodule PhxTodo.Repo.Migrations.CreateSharedLists do
  use Ecto.Migration

  def change do
    create table(:shared_lists) do
      add :list_id, references(:lists, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps(type: :utc_datetime)
    end

    create index(:shared_lists, [:list_id])
    create index(:shared_lists, [:user_id])
  end
end
