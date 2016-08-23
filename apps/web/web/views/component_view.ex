defmodule Web.ComponentView do
  use Web.Web, :view

  def render("index.json", %{components: components}) do
    %{data: render_many(components, Web.ComponentView, "component.json")}
  end

  def render("show.json", %{component: component}) do
    %{data: render_one(component, Web.ComponentView, "component.json")}
  end

  def render("component.json", %{component: component}) do
    %{id: component.id, name: component.name, description_plaintext: component.description_plaintext}
  end
end
