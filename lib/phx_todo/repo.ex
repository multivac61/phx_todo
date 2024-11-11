defmodule PhxTodo.Repo do
  use Ecto.Repo,
    otp_app: :phx_todo,
    adapter: Ecto.Adapters.Postgres
end
