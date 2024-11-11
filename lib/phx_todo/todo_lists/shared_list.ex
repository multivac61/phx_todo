defmodule PhxTodo.TodoLists.SharedList do
  use Ecto.Schema
  import Ecto.Changeset
  import Ecto.Query

  schema "shared_lists" do
    belongs_to :list, PhxTodo.TodoLists.List
    belongs_to :user, PhxTodo.Accounts.User

    timestamps()
  end

  def changeset(shared_list, attrs) do
    shared_list
    |> cast(attrs, [:list_id, :user_id])
    |> validate_required([:list_id, :user_id])
    |> foreign_key_constraint(:list_id)
    |> foreign_key_constraint(:user_id)
    |> unique_constraint([:list_id, :user_id])
  end

  def get_shared_lists(user_id) do
    from(sl in __MODULE__,
      join: l in assoc(sl, :list),
      where: sl.user_id == ^user_id,
      preload: [list: l]
    )
  end
end
