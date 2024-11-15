defmodule PhxTodoWeb.TodoLive.Index do
  use PhxTodoWeb, :live_view

  alias PhxTodo.Todos

  @impl true
  def mount(_params, session, socket) do
    user = PhxTodo.Accounts.get_user_by_session_token(session["user_token"])

    {:ok,
     socket
     |> assign(:current_user, user)
     |> assign(:filters, %{search: "", status: "all"})
     |> assign(:new_todo, "")
     |> stream(:todos, Todos.list_todos(user))}
  end

  @impl true
  def handle_event("toggle", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id, socket.assigns.current_user.id)
    {:ok, updated_todo} = Todos.toggle_todo(todo)

    if matches_filters?(updated_todo, socket.assigns.filters) do
      {:noreply, stream_insert(socket, :todos, updated_todo)}
    else
      {:noreply, stream_delete(socket, :todos, todo)}
    end
  end

  @impl true
  def handle_event("update_title", %{"id" => id, "value" => title}, socket) do
    todo = Todos.get_todo!(id, socket.assigns.current_user.id)

    case Todos.update_todo(todo, %{title: title}) do
      {:ok, updated_todo} ->
        if matches_filters?(updated_todo, socket.assigns.filters) do
          {:noreply, stream_insert(socket, :todos, updated_todo)}
        else
          {:noreply, stream_delete(socket, :todos, todo)}
        end

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("search", %{"value" => search}, socket) do
    filters = Map.put(socket.assigns.filters, :search, search)
    todos = Todos.list_todos(socket.assigns.current_user, filters)

    {:noreply,
     socket
     |> assign(:filters, filters)
     |> stream(:todos, todos, reset: true)}
  end

  @impl true
  def handle_event("filter-status", %{"status" => status}, socket) do
    filters = Map.put(socket.assigns.filters, :status, status)
    todos = Todos.list_todos(socket.assigns.current_user, filters)

    {:noreply,
     socket
     |> assign(:filters, filters)
     |> stream(:todos, todos, reset: true)}
  end

  # Update the create and validate event handlers:
  @impl true
  def handle_event("create", %{"title" => title}, socket) when title != "" do
    case Todos.create_todo(%{
           "title" => title,
           "completed" => false,
           "user_id" => socket.assigns.current_user.id
         }) do
      {:ok, todo} ->
        if matches_filters?(todo, socket.assigns.filters) do
          {:noreply,
           socket
           |> assign(:new_todo, "")
           |> stream_insert(:todos, todo)}
        else
          {:noreply, assign(socket, :new_todo, "")}
        end

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("create", _, socket), do: {:noreply, socket}

  @impl true
  def handle_event("validate", %{"title" => title}, socket) do
    {:noreply, assign(socket, :new_todo, title)}
  end

  defp matches_filters?(todo, filters) do
    matches_search?(todo, filters.search) and matches_status?(todo, filters.status)
  end

  defp matches_search?(_todo, ""), do: true

  defp matches_search?(todo, search) do
    String.contains?(
      String.downcase(todo.title),
      String.downcase(search)
    )
  end

  defp matches_status?(_todo, "all"), do: true
  defp matches_status?(todo, "completed"), do: todo.completed
  defp matches_status?(todo, "pending"), do: not todo.completed

  @impl true
  def render(assigns) do
    ~H"""
    <div class="max-w-4xl mx-auto px-4 sm:px-6 lg:px-8 py-8">
      <div class="mb-8 space-y-4">
        <.form
          :let={f}
          for={%{}}
          phx-submit="create"
          phx-change="validate"
          class="flex gap-4 items-end"
        >
          <div class="flex-1">
            <.input
              type="text"
              name="title"
              value={@new_todo}
              placeholder="Add a new todo..."
              autocomplete="off"
            />
          </div>
          <.button type="submit">Add Todo</.button>
        </.form>

        <div class="flex gap-4 items-end">
          <div class="flex-1">
            <.input
              type="text"
              name="search"
              value={@filters.search}
              placeholder="Search todos..."
              phx-debounce="300"
              phx-keyup="search"
            />
          </div>
          <div class="flex gap-2">
            <.link
              phx-click="filter-status"
              phx-value-status="all"
              class={[
                "px-3 py-2 rounded-md text-sm font-medium",
                @filters.status == "all" && "bg-zinc-800 text-white",
                @filters.status != "all" && "bg-zinc-100 text-zinc-900 hover:bg-zinc-200"
              ]}
            >
              All
            </.link>
            <.link
              phx-click="filter-status"
              phx-value-status="pending"
              class={[
                "px-3 py-2 rounded-md text-sm font-medium",
                @filters.status == "pending" && "bg-zinc-800 text-white",
                @filters.status != "pending" && "bg-zinc-100 text-zinc-900 hover:bg-zinc-200"
              ]}
            >
              Pending
            </.link>
            <.link
              phx-click="filter-status"
              phx-value-status="completed"
              class={[
                "px-3 py-2 rounded-md text-sm font-medium",
                @filters.status == "completed" && "bg-zinc-800 text-white",
                @filters.status != "completed" && "bg-zinc-100 text-zinc-900 hover:bg-zinc-200"
              ]}
            >
              Completed
            </.link>
          </div>
        </div>
      </div>

      <.table id="todos" rows={@streams.todos}>
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
          <input
            type="text"
            value={todo.title}
            phx-debounce="300"
            phx-keyup="update_title"
            phx-value-id={todo.id}
            class={[
              "w-full bg-transparent px-2 py-1 border-zinc-200 rounded-md focus:border-zinc-400 focus:ring-zinc-400/10",
              todo.completed && "line-through text-zinc-400"
            ]}
          />
        </:col>
      </.table>
    </div>
    """
  end
end
