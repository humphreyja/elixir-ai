defmodule Web.Repo.Migrations.CreateComponentRelatedComponent do
  use Ecto.Migration

  def change do
    create table(:component_related_components) do
      add :component_id, references(:components, on_delete: :nothing)
      add :related_component_id, references(:components, on_delete: :nothing)

      timestamps
    end
    create index(:component_related_components, [:component_id])
    create index(:component_related_components, [:related_component_id])

  end
end
