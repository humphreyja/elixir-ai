defmodule Web.ComponentRelatedComponent do
  use Web.Web, :model

  schema "component_related_components" do
    belongs_to :component, Web.Component
    belongs_to :related_component, Web.Component

    timestamps
  end

  @required_fields ~w()
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
  end
end
