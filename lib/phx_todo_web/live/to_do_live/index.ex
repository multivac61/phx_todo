defmodule PhxTodoWeb.ToDoLive.Index do
  use PhxTodoWeb, :live_view

  alias PhxTodo.ToDos
  alias PhxTodo.ToDos.ToDo

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      EctoWatch.subscribe({ToDo, :inserted})
      EctoWatch.subscribe({ToDo, :updated})
      EctoWatch.subscribe({ToDo, :deleted})
    end

    {:ok, stream(socket, :todos, ToDos.list_todos())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit To do")
    |> assign(:to_do, ToDos.get_to_do!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New To do")
    |> assign(:to_do, %ToDo{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Todos")
    |> assign(:to_do, nil)
  end

  @impl true
  def handle_info({PhxTodoWeb.ToDoLive.FormComponent, {:saved, to_do}}, socket) do
    {:noreply, stream_insert(socket, :todos, to_do)}
  end

  def handle_info({{ToDo, :inserted}, %{id: id}}, socket) do
    to_do = ToDos.get_to_do!(id)
    socket = stream_insert(socket, :todos, to_do)

    {:noreply, socket}
  end

  def handle_info({{ToDo, :updated}, %{id: id}}, socket) do
    to_do = ToDos.get_to_do!(id)
    socket = stream_insert(socket, :todos, to_do)

    {:noreply, socket}
  end

  def handle_info({{ToDo, :deleted}, %{id: id}}, socket) do
    socket = stream_delete_by_dom_id(socket, :todos, "todos-#{id}")

    {:noreply, socket}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    to_do = ToDos.get_to_do!(id)
    {:ok, _} = ToDos.delete_to_do(to_do)

    {:noreply, stream_delete(socket, :todos, to_do)}
  end
end
