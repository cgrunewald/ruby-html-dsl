require 'test/unit'
require 'rubui/builder'

include Rubui

class TestVoidElements < Test::Unit::TestCase
  def test_void_element_renders_self_closing
    assert_equal('<br/>', VoidElement.new('br').stringify)
  end

  def test_void_element_with_attributes
    element = VoidElement.new('img', 'src' => 'a.png', 'alt' => 'A & B')
    assert_equal('<img src="a.png" alt="A &amp; B"/>', element.stringify)
  end

  def test_void_element_with_children_is_invalid
    element = VoidElement.new('br', {}, TextElement.new('x'))
    assert(!element.validate)
    assert_raise(ArgumentError) { element.stringify }
  end

  def test_void_predicate
    assert(VoidElement.void?('input'))
    assert(VoidElement.void?(:meta))
    assert(!VoidElement.void?('div'))
  end

  def test_builder_void_elements
    element = UI {
      div {
        meta 'charset' => 'utf-8'
        link 'rel' => 'stylesheet', 'href' => 'a.css'
        img 'src' => 'a.png'
        br
        input 'type' => 'text', 'name' => 'q'
        hr
      }
    }
    assert_equal('<div><meta charset="utf-8"/><link rel="stylesheet" href="a.css"/>' \
                 '<img src="a.png"/><br/><input type="text" name="q"/><hr/></div>',
                 element.stringify)
  end

  def test_builder_top_level_void_element
    assert_equal('<br/>', UI { br }.stringify)
  end

  def test_builder_void_element_rejects_block
    assert_raise(ArgumentError) do
      UI { br { 'nope' } }
    end
  end
end
