defmodule PhxTodoWeb.TodoLive.Index do
  use PhxTodoWeb, :live_view

  alias PhxTodo.Todos
  alias PhxTodo.Todos.Todo

  @impl true
  def mount(_params, session, socket) do
    user = PhxTodo.Accounts.get_user_by_session_token(session["user_token"])

    socket
    |> stream(:todos, Todos.list_todos(user))
    |> assign(:current_user, user)
    |> then(&{:ok, &1})
  end

  @impl true
  def handle_params(params, _url, socket) do
    socket |> apply_action(socket.assigns.live_action, params) |> then(&{:noreply, &1})
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Todo")
    |> assign(:todo, Todos.get_todo!(id, socket.assigns.current_user.id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Todo")
    |> assign(:todo, %Todo{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Todos")
    |> assign(:todo, nil)
  end

  @impl true
  def handle_info({PhxTodoWeb.TodoLive.FormComponent, {:saved, todo}}, socket) do
    socket |> stream_insert(:todos, todo) |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id, socket.assigns.current_user.id)
    {:ok, _} = Todos.delete_todo(todo)
    socket |> stream_delete(:todos, todo) |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("toggle", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id, socket.assigns.current_user.id)
    {:ok, updated_todo} = Todos.toggle_todo(todo)
    socket |> stream_insert(:todos, updated_todo) |> then(&{:noreply, &1})
  end

  @impl true
  def render(assigns) do
    ~H"""
    <.header>
      Listing Todos
      <:actions>
        <.link patch={~p"/todos/new"}>
          <.button>New Todo</.button>
        </.link>
      </:actions>
    </.header>

    <.table
      id="todos"
      rows={@streams.todos}
      row_click={fn {_id, todo} -> JS.navigate(~p"/todos/#{todo}") end}
    >
      <:col :let={{_id, todo}} label="Status">
        <input
          type="checkbox"
          checked={todo.completed}
          phx-click="toggle"
          phx-value-id={todo.id}
          class="h-4 w-4 rounded border-zinc-300 text-zinc-900 focus:ring-zinc-500"
        />
      </:col>
      <:col :let={{_id, todo}} label="Title">
        <span class={todo.completed && "line-through text-zinc-400"}>
          <%= todo.title %>
        </span>
      </:col>
      <:action :let={{_id, todo}}>
        <div class="sr-only">
          <.link navigate={~p"/todos/#{todo}"}>Show</.link>
        </div>
        <.link patch={~p"/todos/#{todo}/edit"}>Edit</.link>
      </:action>
      <:action :let={{id, todo}}>
        <.link
          phx-click={JS.push("delete", value: %{id: todo.id}) |> hide("##{id}")}
          data-confirm="Are you sure?"
        >
          Delete
        </.link>
      </:action>
    </.table>

    <.modal :if={@live_action in [:new, :edit]} id="todo-modal" show on_cancel={JS.patch(~p"/todos")}>
      <.live_component
        module={PhxTodoWeb.TodoLive.FormComponent}
        id={@todo.id || :new}
        title={@page_title}
        action={@live_action}
        todo={@todo}
        current_user={@current_user}
        patch={~p"/todos"}
      />
    </.modal>
    """
  end
end
