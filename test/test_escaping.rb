require 'test/unit'
require 'rubui/builder'

include Rubui

class TestEscaping < Test::Unit::TestCase
  def test_escape_html
    assert_equal('&lt;a href=&quot;x&quot;&gt;Tom &amp; Jerry&#39;s&lt;/a&gt;',
                 Rubui.escape_html('<a href="x">Tom & Jerry\'s</a>'))
  end

  def test_escape_html_non_string
    assert_equal('42', Rubui.escape_html(42))
  end

  def test_text_element_is_escaped
    text_element = TextElement.new('<script>alert(1)</script>')
    assert(text_element.validate)
    assert_equal('&lt;script&gt;alert(1)&lt;/script&gt;', text_element.stringify)
  end

  def test_raw_element_is_not_escaped
    raw_element = RawElement.new('<b>bold</b>')
    assert(raw_element.validate)
    assert_equal('<b>bold</b>', raw_element.stringify)
  end

  def test_attribute_values_are_escaped
    element = PrimitiveElement.new('div', 'title' => '"quoted" & <tagged>')
    assert_equal('<div title="&quot;quoted&quot; &amp; &lt;tagged&gt;"/>', element.stringify)
  end

  def test_builder_text_is_escaped
    element = UI {
      div { text { 'a < b && c > d' } }
    }
    assert_equal('<div>a &lt; b &amp;&amp; c &gt; d</div>', element.stringify)
  end

  def test_builder_bare_string_is_escaped
    element = UI {
      span { '<i>not italic</i>' }
    }
    assert_equal('<span>&lt;i&gt;not italic&lt;/i&gt;</span>', element.stringify)
  end

  def test_builder_top_level_bare_string_is_escaped
    element = UI { '1 < 2' }
    assert_equal('1 &lt; 2', element.stringify)
  end

  def test_builder_attribute_is_escaped
    element = UI {
      div 'data-x' => '"><script>' do
        'ok'
      end
    }
    assert_equal('<div data-x="&quot;&gt;&lt;script&gt;">ok</div>', element.stringify)
  end

  def test_builder_raw
    element = UI {
      div {
        raw { '<em>trusted</em>' }
      }
    }
    assert_equal('<div><em>trusted</em></div>', element.stringify)
  end
end
