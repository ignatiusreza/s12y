defmodule S12y.Project.ConfigurationTest do
  use S12y.DataCase, async: true
  import S12y.Fixture

  alias S12y.Project

  describe "changeset/2" do
    @fixture_file_content read_fixture!("parsers/mix/mix_new/input")
    @attrs %{
      "mix" => %{filename: "mix.exs", content: @fixture_file_content}
    }

    test "cast filename into parser if recognized" do
      Enum.each(@attrs, fn {expected, attr} ->
        changeset = Project.Configuration.changeset(%Project.Configuration{}, attr)
        %{parser: parser} = changeset.changes

        assert parser == expected
      end)
    end
  end
end
