defmodule PhxTodo.ToDosTest do
  use PhxTodo.DataCase

  alias PhxTodo.ToDos

  describe "todos" do
    alias PhxTodo.ToDos.ToDo

    import PhxTodo.ToDosFixtures

    @invalid_attrs %{name: nil, done: nil}

    test "list_todos/0 returns all todos" do
      to_do = to_do_fixture()
      assert ToDos.list_todos() == [to_do]
    end

    test "get_to_do!/1 returns the to_do with given id" do
      to_do = to_do_fixture()
      assert ToDos.get_to_do!(to_do.id) == to_do
    end

    test "create_to_do/1 with valid data creates a to_do" do
      valid_attrs = %{name: "some name", done: true}

      assert {:ok, %ToDo{} = to_do} = ToDos.create_to_do(valid_attrs)
      assert to_do.name == "some name"
      assert to_do.done == true
    end

    test "create_to_do/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = ToDos.create_to_do(@invalid_attrs)
    end

    test "update_to_do/2 with valid data updates the to_do" do
      to_do = to_do_fixture()
      update_attrs = %{name: "some updated name", done: false}

      assert {:ok, %ToDo{} = to_do} = ToDos.update_to_do(to_do, update_attrs)
      assert to_do.name == "some updated name"
      assert to_do.done == false
    end

    test "update_to_do/2 with invalid data returns error changeset" do
      to_do = to_do_fixture()
      assert {:error, %Ecto.Changeset{}} = ToDos.update_to_do(to_do, @invalid_attrs)
      assert to_do == ToDos.get_to_do!(to_do.id)
    end

    test "delete_to_do/1 deletes the to_do" do
      to_do = to_do_fixture()
      assert {:ok, %ToDo{}} = ToDos.delete_to_do(to_do)
      assert_raise Ecto.NoResultsError, fn -> ToDos.get_to_do!(to_do.id) end
    end

    test "change_to_do/1 returns a to_do changeset" do
      to_do = to_do_fixture()
      assert %Ecto.Changeset{} = ToDos.change_to_do(to_do)
    end
  end
end
