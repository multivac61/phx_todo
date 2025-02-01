defmodule PhxTodoWeb.ToDoLive.Index do
  use PhxTodoWeb, :live_view
  import PhxTodoWeb.LiveHelpers

  alias PhxTodo.ToDos
  alias PhxTodo.ToDos.ToDo

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      EctoWatch.subscribe({ToDo, :inserted})
      EctoWatch.subscribe({ToDo, :updated})
      EctoWatch.subscribe({ToDo, :deleted})
    end

    socket |> stream(:todos, ToDos.list_todos()) |> ok()
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket |> apply_action(socket.assigns.live_action, params) |> noreply()
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit")
    |> assign(:to_do, ToDos.get_to_do!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New")
    |> assign(:to_do, %ToDo{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Todos")
    |> assign(:to_do, nil)
  end

  @impl true
  def handle_info({PhxTodoWeb.ToDoLive.FormComponent, {:saved, to_do}}, socket) do
    socket |> stream_insert(:todos, to_do) |> noreply()
  end

  def handle_info({{ToDo, :deleted}, %{id: id}}, socket) do
    socket |> stream_delete_by_dom_id(:todos, "todos-#{id}") |> noreply()
  end

  def handle_info({{ToDo, :inserted}, %{id: id}}, socket) do
    socket |> stream_insert(:todos, ToDos.get_to_do!(id)) |> noreply()
  end

  def handle_info({{ToDo, :updated}, %{id: id}}, socket) do
    to_do = ToDos.get_to_do!(id)

    socket |> stream_delete(:todos, to_do) |> stream_insert(:todos, to_do) |> noreply()
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    to_do = ToDos.get_to_do!(id)
    {:ok, _} = ToDos.delete_to_do(to_do)

    socket |> stream_delete(:todos, to_do) |> noreply()
  end
end
