defmodule Web.ComponentTest do
  use Web.ModelCase

  alias Web.Component

  @valid_attrs %{}
  @invalid_attrs %{}

  test "changeset with valid attributes" do
    changeset = Component.changeset(%Component{}, @valid_attrs)
    assert changeset.valid?
  end

  test "changeset with invalid attributes" do
    changeset = Component.changeset(%Component{}, @invalid_attrs)
    refute changeset.valid?
  end
end
