defmodule DevWizard.PageControllerTest do
  use DevWizard.ConnCase

  test "GET /" do
    conn = get conn(), "/"
    assert html_response(conn, 200) =~ "Dev Wizard"
  end
end
