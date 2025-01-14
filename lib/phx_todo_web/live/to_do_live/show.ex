defmodule PhxTodoWeb.ToDoLive.Show do
  use PhxTodoWeb, :live_view

  alias PhxTodo.ToDos

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:to_do, ToDos.get_to_do!(id))}
  end

  defp page_title(:show), do: "Show To do"
  defp page_title(:edit), do: "Edit"
end
