defmodule PhxTodoWeb.ToDoLive.FormComponent do
  use PhxTodoWeb, :live_component

  alias PhxTodo.ToDos

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        {@title}
        <:subtitle>Use this form to manage to_do records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="to_do-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <.input field={@form[:done]} type="checkbox" label="Done" />
        <:actions>
          <.button phx-disable-with="Saving...">Save</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{to_do: to_do} = assigns, socket) do
    {:ok,
     socket
     |> assign(assigns)
     |> assign_new(:form, fn ->
       to_form(ToDos.change_to_do(to_do))
     end)}
  end

  @impl true
  def handle_event("validate", %{"to_do" => to_do_params}, socket) do
    changeset = ToDos.change_to_do(socket.assigns.to_do, to_do_params)
    {:noreply, assign(socket, form: to_form(changeset, action: :validate))}
  end

  def handle_event("save", %{"to_do" => to_do_params}, socket) do
    save_to_do(socket, socket.assigns.action, to_do_params)
  end

  defp save_to_do(socket, :edit, to_do_params) do
    case ToDos.update_to_do(socket.assigns.to_do, to_do_params) do
      {:ok, to_do} ->
        notify_parent({:saved, to_do})

        {:noreply,
         socket
         |> put_flash(:info, "To do updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp save_to_do(socket, :new, to_do_params) do
    case ToDos.create_to_do(to_do_params) do
      {:ok, to_do} ->
        notify_parent({:saved, to_do})

        {:noreply,
         socket
         |> put_flash(:info, "To do created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, form: to_form(changeset))}
    end
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
