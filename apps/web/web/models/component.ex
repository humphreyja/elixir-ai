defmodule Web.Component do
  use Web.Web, :model

  schema "components" do
    field :name, :string
    field :synonyms, {:array, :text}
    field :description_markdown, :string
    field :description_plaintext, :string
    field :root, :boolean
    has_many :component_related_components, Web.ComponentRelatedComponent
    has_many :related_components, through: [:component_related_components, :related_component]
    has_many :subcomponents, through: [:component_related_components, :related_component]
    has_many :parent_components, through: [:component_related_components, :component]
    timestamps
  end

  @required_fields ~w(name description_plaintext)
  @optional_fields ~w()

  @doc """
  Creates a changeset based on the `model` and `params`.

  If no params are provided, an invalid changeset is returned
  with no validation performed.
  """
  def changeset(model, params \\ :empty) do
    model
    |> cast(params, @required_fields, @optional_fields)
    |> cast_assoc(:related_component_ids)
  end
end
