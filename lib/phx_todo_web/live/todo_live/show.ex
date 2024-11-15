defmodule PhxTodoWeb.TodoLive.Show do
  use PhxTodoWeb, :live_view

  alias PhxTodo.Todos

  @impl true
  def mount(_params, session, socket) do
    user = PhxTodo.Accounts.get_user_by_session_token(session["user_token"])
    {:ok, assign(socket, :current_user, user)}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    todo = Todos.get_todo!(id, socket.assigns.current_user.id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:todo, todo)}
  end

  @impl true
  def handle_event("toggle", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id, socket.assigns.current_user.id)
    {:ok, updated_todo} = Todos.toggle_todo(todo)

    {:noreply, assign(socket, :todo, updated_todo)}
  end

  defp page_title(:show), do: "Show Todo"
  defp page_title(:edit), do: "Edit Todo"

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Todo <%= @todo.id %>
      <:subtitle>This is a todo record from your database.</:subtitle>
      <:actions>
        <.link patch={~p"/todos/#{@todo}/show/edit"} phx-click={JS.push_focus()}>
          <.button>Edit todo</.button>
        </.link>
      </:actions>
    </.header>

    <.table id="todo" rows={[@todo]}>
      <:col :let={todo} label="Status">
        <input
          type="checkbox"
          checked={todo.completed}
          phx-click="toggle"
          phx-value-id={todo.id}
          class="h-4 w-4 rounded border-zinc-300 text-zinc-900 focus:ring-zinc-500"
        />
      </:col>
      <:col :let={todo} label="Title">
        <span class={todo.completed && "line-through text-zinc-400"}>
          <%= todo.title %>
        </span>
      </:col>
    </.table>

    <.back navigate={~p"/todos"}>Back to todos</.back>

    <.modal :if={@live_action == :edit} id="todo-modal" show on_cancel={JS.patch(~p"/todos/#{@todo}")}>
      <.live_component
        module={PhxTodoWeb.TodoLive.FormComponent}
        id={@todo.id}
        title={@page_title}
        action={@live_action}
        todo={@todo}
        current_user={@current_user}
        patch={~p"/todos/#{@todo}"}
      />
    </.modal>
    """
  end
end
