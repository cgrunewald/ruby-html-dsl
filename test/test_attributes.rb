require 'test/unit'
require 'rubui/builder'

include Rubui

class TestAttributes < Test::Unit::TestCase
  def test_true_renders_boolean_attribute
    element = PrimitiveElement.new('input', 'type' => 'checkbox', 'checked' => true)
    assert_equal('<input type="checkbox" checked/>', element.stringify)
  end

  def test_false_and_nil_are_omitted
    element = PrimitiveElement.new('button', disabled: false, title: nil, id: 'b')
    assert_equal('<button id="b"/>', element.stringify)
  end

  def test_symbol_keys
    element = PrimitiveElement.new('div', class: 'box', id: 'main')
    assert_equal('<div class="box" id="main"/>', element.stringify)
  end

  def test_data_hash_expands
    element = PrimitiveElement.new('div', data: { user_id: 42, role: 'admin' })
    assert_equal('<div data-user-id="42" data-role="admin"/>', element.stringify)
  end

  def test_nested_hash_values_follow_boolean_rules
    element = PrimitiveElement.new('div', data: { active: true, hidden: false, missing: nil })
    assert_equal('<div data-active/>', element.stringify)
  end

  def test_aria_hash_expands
    element = PrimitiveElement.new('span', aria: { label: 'Close', hidden: 'true' })
    assert_equal('<span aria-label="Close" aria-hidden="true"/>', element.stringify)
  end

  def test_hash_values_are_escaped
    element = PrimitiveElement.new('div', data: { x: '"><script>' })
    assert_equal('<div data-x="&quot;&gt;&lt;script&gt;"/>', element.stringify)
  end

  def test_builder_boolean_and_data_attributes
    element = UI {
      div hidden: true, draggable: false, data: { id: 7 } do
        'hi'
      end
    }
    assert_equal('<div hidden data-id="7">hi</div>', element.stringify)
  end
end
