defmodule Web.ComponentController do
  use Web.Web, :controller

  alias Web.Component

  plug :scrub_params, "component" when action in [:create, :update]

  def index(conn, _params) do
    components = Repo.all(Component)
    render(conn, "index.json", components: components)
  end

  def create(conn, %{"component" => component_params}) do
    changeset = Component.changeset(%Component{}, component_params)

    case Repo.insert(changeset) do
      {:ok, component} ->
        conn
        |> put_status(:created)
        |> put_resp_header("location", component_path(conn, :show, component))
        |> render("show.json", component: component)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Web.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    component = Repo.get!(Component, id)
    render(conn, "show.json", component: component)
  end

  def update(conn, %{"id" => id, "component" => component_params}) do
    component = Repo.get!(Component, id)
    changeset = Component.changeset(component, component_params)

    case Repo.update(changeset) do
      {:ok, component} ->
        render(conn, "show.json", component: component)
      {:error, changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(Web.ChangesetView, "error.json", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    component = Repo.get!(Component, id)

    # Here we use delete! (with a bang) because we expect
    # it to always work (and if it does not, it will raise).
    Repo.delete!(component)

    send_resp(conn, :no_content, "")
  end
end
