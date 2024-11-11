defmodule PhxTodoWeb.TodoController do
  use PhxTodoWeb, :controller

  alias PhxTodo.TodoLists
  alias PhxTodo.TodoLists.Todo

  def action(conn, _) do
    list_id = conn.path_params["list_id"]
    args = [conn, conn.params, list_id]
    apply(__MODULE__, action_name(conn), args)
  end

  def index(conn, _params, list_id) do
    todos = TodoLists.get_todos_for_list(list_id)
    render(conn, :index, todos: todos, list_id: list_id)
  end

  def new(conn, _params, list_id) do
    changeset = TodoLists.change_todo(%Todo{})
    render(conn, :new, changeset: changeset, list_id: list_id)
  end

  def create(conn, %{"title" => title}, list_id) do
    current_user = conn.assigns.current_user

    todo_params = %{
      "title" => title,
      "list_id" => list_id,
      "user_id" => current_user.id
    }

    case TodoLists.create_todo(todo_params) do
      {:ok, _todo} ->
        conn
        |> put_flash(:info, "Todo created successfully.")
        |> redirect(to: ~p"/lists/#{list_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :new, changeset: changeset, list_id: list_id)
    end
  end

  def edit(conn, %{"id" => id}, list_id) do
    todo = TodoLists.get_todo!(id)
    changeset = TodoLists.change_todo(todo)
    render(conn, :edit, todo: todo, changeset: changeset, list_id: list_id)
  end

  def update(conn, %{"id" => id, "todo" => todo_params}, list_id) do
    todo = TodoLists.get_todo!(id)

    case TodoLists.update_todo(todo, todo_params) do
      {:ok, _todo} ->
        conn
        |> put_flash(:info, "Todo updated successfully.")
        |> redirect(to: ~p"/lists/#{list_id}")

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, :edit, todo: todo, changeset: changeset, list_id: list_id)
    end
  end

  def delete(conn, %{"id" => id}, list_id) do
    todo = TodoLists.get_todo!(id)
    {:ok, _todo} = TodoLists.delete_todo(todo)

    conn
    |> put_flash(:info, "Todo deleted successfully.")
    |> redirect(to: ~p"/lists/#{list_id}")
  end

  def toggle(conn, %{"todo_id" => id}, list_id) do
    todo = TodoLists.get_todo!(id)
    {:ok, _todo} = TodoLists.toggle_todo(todo)

    conn
    |> redirect(to: ~p"/lists/#{list_id}")
  end
end
