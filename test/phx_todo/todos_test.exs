defmodule PhxTodo.TodosTest do
  use PhxTodo.DataCase

  alias PhxTodo.Todos
  alias PhxTodo.Accounts

  describe "todos" do
    alias PhxTodo.Todos.Todo

    import PhxTodo.TodosFixtures
    import PhxTodo.AccountsFixtures

    @invalid_attrs %{completed: nil, title: nil}

    setup do
      user = user_fixture()
      %{user: user}
    end

    test "list_todos/1 returns all todos for given user", %{user: user} do
      todo = todo_fixture(%{user_id: user.id})
      other_user = user_fixture()
      _other_todo = todo_fixture(%{user_id: other_user.id})

      assert Todos.list_todos(user) == [todo]
    end

    test "get_todo!/2 returns the todo with given id for the user", %{user: user} do
      todo = todo_fixture(%{user_id: user.id})
      assert Todos.get_todo!(todo.id, user.id) == todo
    end

    test "get_todo!/2 raises for todo belonging to different user", %{user: user} do
      other_user = user_fixture()
      todo = todo_fixture(%{user_id: other_user.id})

      assert_raise Ecto.NoResultsError, fn ->
        Todos.get_todo!(todo.id, user.id)
      end
    end

    test "create_todo/1 with valid data creates a todo", %{user: user} do
      valid_attrs = %{completed: true, title: "some title", user_id: user.id}

      assert {:ok, %Todo{} = todo} = Todos.create_todo(valid_attrs)
      assert todo.completed == true
      assert todo.title == "some title"
      assert todo.user_id == user.id
    end

    test "create_todo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Todos.create_todo(@invalid_attrs)
    end

    test "update_todo/2 with valid data updates the todo", %{user: user} do
      todo = todo_fixture(%{user_id: user.id})
      update_attrs = %{completed: false, title: "some updated title"}

      assert {:ok, %Todo{} = todo} = Todos.update_todo(todo, update_attrs)
      assert todo.completed == false
      assert todo.title == "some updated title"
    end

    test "update_todo/2 with invalid data returns error changeset", %{user: user} do
      todo = todo_fixture(%{user_id: user.id})
      assert {:error, %Ecto.Changeset{}} = Todos.update_todo(todo, @invalid_attrs)
      assert todo == Todos.get_todo!(todo.id, user.id)
    end

    test "delete_todo/1 deletes the todo", %{user: user} do
      todo = todo_fixture(%{user_id: user.id})
      assert {:ok, %Todo{}} = Todos.delete_todo(todo)
      assert_raise Ecto.NoResultsError, fn -> Todos.get_todo!(todo.id, user.id) end
    end

    test "change_todo/1 returns a todo changeset", %{user: user} do
      todo = todo_fixture(%{user_id: user.id})
      assert %Ecto.Changeset{} = Todos.change_todo(todo)
    end

    test "toggle_todo/1 toggles the completed status", %{user: user} do
      todo = todo_fixture(%{user_id: user.id, completed: false})
      assert {:ok, %Todo{completed: true}} = Todos.toggle_todo(todo)

      todo = todo_fixture(%{user_id: user.id, completed: true})
      assert {:ok, %Todo{completed: false}} = Todos.toggle_todo(todo)
    end
  end
end
