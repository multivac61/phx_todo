defmodule PhxTodo.Repo.Migrations.CreateSharedLists do
  use Ecto.Migration

  def change do
    create table(:shared_lists) do
      add :list_id, references(:lists, on_delete: :delete_all), null: false
      add :user_id, references(:users, on_delete: :delete_all), null: false

      timestamps()
    end

    # Add indexes for performance and uniqueness
    create index(:shared_lists, [:list_id])
    create index(:shared_lists, [:user_id])
    create unique_index(:shared_lists, [:list_id, :user_id])
  end
end
