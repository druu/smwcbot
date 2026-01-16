defmodule SMWCWeb.ErrorJSONTest do
  use SMWCWeb.ConnCase, async: true

  test "renders 404" do
    assert SMWCWeb.ErrorJSON.render("404.json", %{}) == %{errors: %{detail: "Not Found"}}
  end

  test "renders 500" do
    assert SMWCWeb.ErrorJSON.render("500.json", %{}) ==
             %{errors: %{detail: "Internal Server Error"}}
  end
end
