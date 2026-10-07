require 'test/unit'
require 'rubui/builder'

class TestBuilder < Test::Unit::TestCase
  
  def test_text_element_creation
    element = UI {
      text { "This is a test" }
    }
    assert_equal("This is a test", element.stringify)
  end

  def test_primitive_element_creation
    element = UI {
      div
    }
    assert_equal("<div/>", element.stringify)
  end

  def test_dual_primitive_element_creation
    element = UI {
      div
      div
    }
    assert_equal '<div/><div/>', element.stringify
  end

  def test_text_in_primitive_element
    element = UI {
      div {
        text {
          "This is a test"
        }
      }
    }

    element2 = UI {
      div { "This is a test" }
    }

    assert_equal '<div>This is a test</div>', element.stringify
    assert_equal element.stringify, element2.stringify
  end

  def test_text_in_primitive_element_with_attributes
    element = UI {
      div 'test' => 'test1' do
        'This is a test'
      end
    }

    assert_equal '<div test="test1">This is a test</div>', element.stringify
  end

  def test_nested_elements
    element = UI {
      div {
        span {
          "Hello"
        }
        text {
          "Hola"
        }
      }
    }

    assert_equal '<div><span>Hello</span>Hola</div>', element.stringify
  end

  def test_multiple_text_nodes_accumulate
    element = UI {
      p {
        text { 'a' }
        raw { '<b>b</b>' }
        text { 'c' }
      }
    }
    assert_equal '<p>a<b>b</b>c</p>', element.stringify
  end

  def test_text_nodes_interleaved_with_elements
    element = UI {
      div {
        text { 'before' }
        span { 'mid' }
        text { 'after' }
      }
    }
    assert_equal '<div>before<span>mid</span>after</div>', element.stringify
  end

  def test_text_node_followed_by_bare_string
    element = UI {
      p {
        text { 'a' }
        'b'
      }
    }
    assert_equal '<p>ab</p>', element.stringify
  end

  def test_multiple_top_level_text_nodes
    element = UI {
      text { 'x' }
      text { 'y' }
    }
    assert_equal 'xy', element.stringify
  end
end
