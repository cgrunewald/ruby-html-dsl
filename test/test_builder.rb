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

end