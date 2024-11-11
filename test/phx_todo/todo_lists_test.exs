defmodule PhxTodo.TodoListsTest do
  use PhxTodo.DataCase

  alias PhxTodo.TodoLists

  describe "lists" do
    alias PhxTodo.TodoLists.List

    import PhxTodo.TodoListsFixtures

    @invalid_attrs %{title: nil}

    test "list_lists/0 returns all lists" do
      list = list_fixture()
      assert TodoLists.list_lists() == [list]
    end

    test "get_list!/1 returns the list with given id" do
      list = list_fixture()
      assert TodoLists.get_list!(list.id) == list
    end

    test "create_list/1 with valid data creates a list" do
      valid_attrs = %{title: "some title"}

      assert {:ok, %List{} = list} = TodoLists.create_list(valid_attrs)
      assert list.title == "some title"
    end

    test "create_list/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TodoLists.create_list(@invalid_attrs)
    end

    test "update_list/2 with valid data updates the list" do
      list = list_fixture()
      update_attrs = %{title: "some updated title"}

      assert {:ok, %List{} = list} = TodoLists.update_list(list, update_attrs)
      assert list.title == "some updated title"
    end

    test "update_list/2 with invalid data returns error changeset" do
      list = list_fixture()
      assert {:error, %Ecto.Changeset{}} = TodoLists.update_list(list, @invalid_attrs)
      assert list == TodoLists.get_list!(list.id)
    end

    test "delete_list/1 deletes the list" do
      list = list_fixture()
      assert {:ok, %List{}} = TodoLists.delete_list(list)
      assert_raise Ecto.NoResultsError, fn -> TodoLists.get_list!(list.id) end
    end

    test "change_list/1 returns a list changeset" do
      list = list_fixture()
      assert %Ecto.Changeset{} = TodoLists.change_list(list)
    end
  end

  describe "todos" do
    alias PhxTodo.TodoLists.Todo

    import PhxTodo.TodoListsFixtures

    @invalid_attrs %{completed: nil, title: nil}

    test "list_todos/0 returns all todos" do
      todo = todo_fixture()
      assert TodoLists.list_todos() == [todo]
    end

    test "get_todo!/1 returns the todo with given id" do
      todo = todo_fixture()
      assert TodoLists.get_todo!(todo.id) == todo
    end

    test "create_todo/1 with valid data creates a todo" do
      valid_attrs = %{completed: true, title: "some title"}

      assert {:ok, %Todo{} = todo} = TodoLists.create_todo(valid_attrs)
      assert todo.completed == true
      assert todo.title == "some title"
    end

    test "create_todo/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TodoLists.create_todo(@invalid_attrs)
    end

    test "update_todo/2 with valid data updates the todo" do
      todo = todo_fixture()
      update_attrs = %{completed: false, title: "some updated title"}

      assert {:ok, %Todo{} = todo} = TodoLists.update_todo(todo, update_attrs)
      assert todo.completed == false
      assert todo.title == "some updated title"
    end

    test "update_todo/2 with invalid data returns error changeset" do
      todo = todo_fixture()
      assert {:error, %Ecto.Changeset{}} = TodoLists.update_todo(todo, @invalid_attrs)
      assert todo == TodoLists.get_todo!(todo.id)
    end

    test "delete_todo/1 deletes the todo" do
      todo = todo_fixture()
      assert {:ok, %Todo{}} = TodoLists.delete_todo(todo)
      assert_raise Ecto.NoResultsError, fn -> TodoLists.get_todo!(todo.id) end
    end

    test "change_todo/1 returns a todo changeset" do
      todo = todo_fixture()
      assert %Ecto.Changeset{} = TodoLists.change_todo(todo)
    end
  end

  describe "shared_lists" do
    alias PhxTodo.TodoLists.SharedList

    import PhxTodo.TodoListsFixtures

    @invalid_attrs %{}

    test "list_shared_lists/0 returns all shared_lists" do
      shared_list = shared_list_fixture()
      assert TodoLists.list_shared_lists() == [shared_list]
    end

    test "get_shared_list!/1 returns the shared_list with given id" do
      shared_list = shared_list_fixture()
      assert TodoLists.get_shared_list!(shared_list.id) == shared_list
    end

    test "create_shared_list/1 with valid data creates a shared_list" do
      valid_attrs = %{}

      assert {:ok, %SharedList{} = shared_list} = TodoLists.create_shared_list(valid_attrs)
    end

    test "create_shared_list/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = TodoLists.create_shared_list(@invalid_attrs)
    end

    test "update_shared_list/2 with valid data updates the shared_list" do
      shared_list = shared_list_fixture()
      update_attrs = %{}

      assert {:ok, %SharedList{} = shared_list} = TodoLists.update_shared_list(shared_list, update_attrs)
    end

    test "update_shared_list/2 with invalid data returns error changeset" do
      shared_list = shared_list_fixture()
      assert {:error, %Ecto.Changeset{}} = TodoLists.update_shared_list(shared_list, @invalid_attrs)
      assert shared_list == TodoLists.get_shared_list!(shared_list.id)
    end

    test "delete_shared_list/1 deletes the shared_list" do
      shared_list = shared_list_fixture()
      assert {:ok, %SharedList{}} = TodoLists.delete_shared_list(shared_list)
      assert_raise Ecto.NoResultsError, fn -> TodoLists.get_shared_list!(shared_list.id) end
    end

    test "change_shared_list/1 returns a shared_list changeset" do
      shared_list = shared_list_fixture()
      assert %Ecto.Changeset{} = TodoLists.change_shared_list(shared_list)
    end
  end
end
