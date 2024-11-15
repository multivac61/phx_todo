defmodule PhxTodoWeb.TodoLive.Index do
  use PhxTodoWeb, :live_view

  alias PhxTodo.Todos

  @impl true
  def mount(_params, session, socket) do
    user = PhxTodo.Accounts.get_user_by_session_token(session["user_token"])

    socket
    |> assign(:current_user, user)
    |> assign(:filters, %{search: "", status: "all"})
    |> assign(:new_todo, "")
    |> assign(:sort, %{by: :inserted_at, order: :desc})
    |> stream(:todos, Todos.list_todos(user))
    |> then(&{:ok, &1})
  end

  defp toggle_sort(by, current_sort) do
    by = String.to_existing_atom(by)

    cond do
      current_sort.by != by -> %{by: by, order: :asc}
      current_sort.order == :asc -> %{by: by, order: :desc}
      true -> %{by: by, order: :asc}
    end
  end

  @impl true
  def handle_event("sort", %{"by" => by}, socket) do
    new_sort = toggle_sort(by, socket.assigns.sort)

    socket
    |> assign(:sort, new_sort)
    |> stream(
      :todos,
      Todos.list_todos(socket.assigns.current_user, socket.assigns.filters, new_sort),
      reset: true
    )
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("toggle", %{"id" => id}, socket) do
    todo = Todos.get_todo!(id, socket.assigns.current_user.id)
    {:ok, updated_todo} = Todos.toggle_todo(todo)

    if matches_filters?(updated_todo, socket.assigns.filters) do
      socket |> stream_insert(:todos, updated_todo) |> then(&{:noreply, &1})
    else
      socket |> stream_delete(:todos, todo) |> then(&{:noreply, &1})
    end
  end

  @impl true
  def handle_event("update_title", %{"id" => id, "value" => title}, socket) do
    todo = Todos.get_todo!(id, socket.assigns.current_user.id)

    case Todos.update_todo(todo, %{title: title}) do
      {:ok, updated_todo} ->
        if matches_filters?(updated_todo, socket.assigns.filters) do
          socket |> stream_insert(:todos, updated_todo) |> then(&{:noreply, &1})
        else
          socket |> stream_delete(:todos, todo) |> then(&{:noreply, &1})
        end

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  @impl true
  def handle_event("search", %{"value" => search}, socket) do
    filters = Map.put(socket.assigns.filters, :search, search)
    todos = Todos.list_todos(socket.assigns.current_user, filters)

    socket
    |> assign(:filters, filters)
    |> stream(:todos, todos, reset: true)
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("filter-status", %{"status" => status}, socket) do
    filters = Map.put(socket.assigns.filters, :status, status)

    socket
    |> assign(:filters, filters)
    |> stream(
      :todos,
      Todos.list_todos(socket.assigns.current_user, filters, socket.assigns.sort),
      reset: true
    )
    |> then(&{:noreply, &1})
  end

  @impl true
  def handle_event("create", %{"title" => title}, socket) when title != "" do
    case Todos.create_todo(%{
           "title" => title,
           "completed" => false,
           "user_id" => socket.assigns.current_user.id
         }) do
      {:ok, _todo} ->
        # NOTE: This fetches the full list again to maintain sort order... not scalable
        todos =
          Todos.list_todos(
            socket.assigns.current_user,
            socket.assigns.filters,
            socket.assigns.sort
          )

        {:noreply,
         socket
         |> assign(:new_todo, "")
         |> stream(:todos, todos, reset: true)}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end

  def handle_event("create", _, socket), do: {:noreply, socket}

  @impl true
  def handle_event("validate", %{"title" => title}, socket) do
    socket |> assign(:new_todo, title) |> then(&{:noreply, &1})
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
        <.form for={%{}} phx-submit="create" phx-change="validate" class="flex gap-4 items-end">
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
        <div class="flex items-center gap-2 justify-end">
          <span class="text-sm font-medium text-zinc-700">
            Sort by:
          </span>
          <div class="inline-flex rounded-md">
            <div class="flex space-x-2">
              <.link
                type="button"
                phx-click="sort"
                phx-value-by="title"
                class={[
                  "px-3 py-2 rounded-md text-sm font-medium",
                  @sort.by == :title && "bg-zinc-800 text-white",
                  @sort.by != :title && "bg-zinc-100 text-zinc-900 hover:bg-zinc-200"
                ]}
              >
                Title
                <%= if @sort.by == :title do %>
                  <%= if @sort.order == :asc do %>
                    <.icon name="hero-arrow-down-mini" class="h-4 w-4" />
                  <% else %>
                    <.icon name="hero-arrow-up-mini" class="h-4 w-4" />
                  <% end %>
                <% end %>
              </.link>
              <.link
                type="button"
                phx-click="sort"
                phx-value-by="completed"
                class={[
                  "px-3 py-2 rounded-md text-sm font-medium",
                  @sort.by == :completed && "bg-zinc-800 text-white",
                  @sort.by != :completed && "bg-zinc-100 text-zinc-900 hover:bg-zinc-200"
                ]}
              >
                Status
                <%= if @sort.by == :completed do %>
                  <%= if @sort.order == :asc do %>
                    <.icon name="hero-arrow-up-mini" class="h-4 w-4" />
                  <% else %>
                    <.icon name="hero-arrow-down-mini" class="h-4 w-4" />
                  <% end %>
                <% end %>
              </.link>
              <.link
                type="button"
                phx-click="sort"
                phx-value-by="inserted_at"
                class={[
                  "px-3 py-2 rounded-md text-sm font-medium",
                  @sort.by == :inserted_at && "bg-zinc-800 text-white",
                  @sort.by != :inserted_at && "bg-zinc-100 text-zinc-900 hover:bg-zinc-200"
                ]}
              >
                Modified
                <%= if @sort.by == :inserted_at do %>
                  <%= if @sort.order == :asc do %>
                    <.icon name="hero-arrow-down-mini" class="h-4 w-4" />
                  <% else %>
                    <.icon name="hero-arrow-up-mini" class="h-4 w-4" />
                  <% end %>
                <% end %>
              </.link>
            </div>
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
