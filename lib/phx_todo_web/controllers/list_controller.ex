defmodule PhxTodoWeb.ListController do
  use PhxTodoWeb, :controller

  alias PhxTodo.TodoLists
  alias PhxTodo.TodoLists.List

   def index(conn, _params) do
    current_user = conn.assigns.current_user
    my_lists = TodoLists.get_user_lists(current_user.id)
    shared_lists = TodoLists.get_shared_lists(current_user.id)

    render(conn, :index, 
      my_lists: my_lists,
      shared_lists: shared_lists,
      current_user: current_user
    )
  end

  def new(conn, _params) do
    changeset = TodoLists.change_list(%List{})
    render(conn, :new, changeset: changeset)
  end

  def create(conn, %{"list" => list_params}) do
    current_user = conn.assigns.current_user
    list_params = Map.put(list_params, "user_id", current_user.id)

    case TodoLists.create_list(list_params) do
      {:ok, list} ->
        conn
        |> put_flash(:info, "List created successfully.")
        |> redirect(to: ~p"/lists/#{list}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    current_user = conn.assigns.current_user
    list = TodoLists.get_list!(id)

    if TodoLists.can_access_list?(list.id, current_user.id) do
      todos = TodoLists.get_todos_for_list(list.id)
      shared_with_users = TodoLists.get_shared_users(list.id)

      render(conn, :show,
        list: list,
        todos: todos,
        shared_with_users: shared_with_users,
        current_user: current_user
      )
    else
      conn
      |> put_flash(:error, "You don't have access to this list")
      |> redirect(to: ~p"/lists")
    end
  end

  def edit(conn, %{"id" => id}) do
    list = TodoLists.get_list!(id)
    changeset = TodoLists.change_list(list)
    render(conn, :edit, list: list, changeset: changeset)
  end

  def update(conn, %{"id" => id, "list" => list_params}) do
    list = TodoLists.get_list!(id)

    case TodoLists.update_list(list, list_params) do
      {:ok, list} ->
        conn
        |> put_flash(:info, "List updated successfully.")
        |> redirect(to: ~p"/lists/#{list}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, list: list, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    list = TodoLists.get_list!(id)
    {:ok, _list} = TodoLists.delete_list(list)

    conn
    |> put_flash(:info, "List deleted successfully.")
    |> redirect(to: ~p"/lists")
  end
end
