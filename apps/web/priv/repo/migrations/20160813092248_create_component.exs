defmodule Web.Repo.Migrations.CreateComponent do
  use Ecto.Migration

  def change do
    create table(:components) do
      add :name, :string
      add :synonyms, {:array, :text}
      add :description_markdown, :text
      add :description_plaintext, :text
      add :root, :boolean

      timestamps
    end

  end
end
