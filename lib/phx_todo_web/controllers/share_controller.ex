defmodule PhxTodoWeb.ShareController do
  use PhxTodoWeb, :controller

  alias PhxTodo.Accounts
  alias PhxTodo.TodoLists

  def create(conn, %{"list_id" => list_id, "email" => email}) do
    current_user = conn.assigns.current_user
    list = TodoLists.get_list!(list_id)

    # Verify the current user owns the list
    if list.user_id == current_user.id do
      case Accounts.get_user_by_email(email) do
        nil ->
          conn
          |> put_flash(:error, "User with that email not found.")
          |> redirect(to: ~p"/lists/#{list_id}")

        user ->
          case TodoLists.share_list(list_id, user.id) do
            {:ok, _shared_list} ->
              conn
              |> put_flash(:info, "List shared successfully with #{email}")
              |> redirect(to: ~p"/lists/#{list_id}")

            {:error, _changeset} ->
              conn
              |> put_flash(:error, "List is already shared with this user")
              |> redirect(to: ~p"/lists/#{list_id}")
          end
      end
    else
      conn
      |> put_flash(:error, "You don't have permission to share this list")
      |> redirect(to: ~p"/lists")
    end
  end

  def delete(conn, %{"list_id" => list_id, "user_id" => user_id}) do
    current_user = conn.assigns.current_user
    list = TodoLists.get_list!(list_id)

    if list.user_id == current_user.id do
      TodoLists.unshare_list(list_id, user_id)

      conn
      |> put_flash(:info, "Sharing removed successfully")
      |> redirect(to: ~p"/lists/#{list_id}")
    else
      conn
      |> put_flash(:error, "You don't have permission to modify this list's sharing")
      |> redirect(to: ~p"/lists")
    end
  end
end
