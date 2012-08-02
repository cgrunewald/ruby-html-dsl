require 'test/unit'
require 'rubui/element'

include Rubui

class TestElement < Test::Unit::TestCase
  def test_text_element
    text_element = TextElement.new("This is a test")
    assert(text_element.validate)
    assert_equal("This is a test", text_element.stringify)
  end

  def test_text_element_invalid
    text_element = TextElement.new(1)
    assert(!text_element.validate, "Text element should not be valid")
  end

  def test_primitive_element
    primitive_element = PrimitiveElement.new('div')
    assert(primitive_element.validate)
    assert_equal('<div/>', primitive_element.stringify)
  end

  def test_primitive_element_attributes
    primitive_element = PrimitiveElement.new('div', {'test' => '1', 'checked' => 'checked'})
    assert(primitive_element.validate)
    assert_equal('<div test="1" checked="checked"/>', primitive_element.stringify)
  end

  def test_primitive_validate_recursive
    text_element = TextElement.new(1)
    primitive_element = PrimitiveElement.new('div', {}, text_element)
    assert(!primitive_element.validate)
  end

  def test_primitive_element_with_text_child
    text_element = TextElement.new("test")
    assert(text_element.validate)
    primitive_element = PrimitiveElement.new('div', {'test' => '1'}, text_element)
    assert_equal('<div test="1">test</div>', primitive_element.stringify)
  end

  def test_primitive_element_with_many_children
    text_element1 = TextElement.new("test1")
    text_element2 = TextElement.new("test2")
    primitive_element1 = PrimitiveElement.new("div", {"test" => "test"})
    primitive_element2 = PrimitiveElement.new("div", {}, text_element1, primitive_element1)
    primitive_element3 = PrimitiveElement.new("div", {"a" => "b"}, primitive_element2, text_element2)
    assert(primitive_element3.validate)
    assert_equal('<div a="b"><div>test1<div test="test"/></div>test2</div>', primitive_element3.stringify)
  end

  class CoolElement < Element
    def render 
      PrimitiveElement.new('div', attributes, *children)
    end
  end

  class UncoolElement < Element
    def render
      CoolElement.new({'test' => 'test'}, CoolElement.new)
    end
  end

  def test_element_1
    element = CoolElement.new
    assert_equal('<div/>', element.stringify)
  end

  def test_element_2
    element = UncoolElement.new
    assert_equal('<div test="test"><div/></div>', element.stringify)
  end
end