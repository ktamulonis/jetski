require_relative "test_helper"

class ModelInspectTest < Minitest::Test
  class Inspectable < Jetski::Model
    attributes :name
  end

  def test_inspect_includes_attributes
    model = Inspectable.new(id: 1, name: "Widget", created_at: "now", updated_at: "later")
    output = model.inspect

    assert_includes output, "#<#{Inspectable}"
    assert_includes output, "id=\"1\""
    assert_includes output, "name=\"Widget\""
    assert_includes output, "created_at=\"now\""
    assert_includes output, "updated_at=\"later\""
  end
end
