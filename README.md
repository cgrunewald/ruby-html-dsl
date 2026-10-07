# Rubui

Rubui is a small Ruby DSL for building HTML. Elements are built with plain
Ruby blocks and rendered to a string, with text and attribute values
HTML-escaped by default.

## Installation

Add this line to your application's Gemfile:

    gem 'rubui'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install rubui

## Usage

Include the `Rubui` module and build a tree with `UI { ... }`. Call
`stringify` on the result to render it.

```ruby
require 'rubui'
include Rubui

page = UI {
  div 'class' => 'card' do
    span { 'Hello' }
    text { ' world' }
  end
}

page.stringify
# => <div class="card"><span>Hello</span> world</div>
```

### Elements

The builder provides `div`, `span`, `p`, `ul`, `ol`, `li`, `dl`, `dt` and
`dd`. Each takes an optional attribute hash and an optional block for its
children. Elements with no children render self-closing (`<div/>`).

A block's string return value becomes a text child:

```ruby
UI { p { 'Some text' } }.stringify   # => <p>Some text</p>
```

### Escaping

Text and attribute values are HTML-escaped:

```ruby
UI { div 'title' => '"x"' do 'a < b' end }.stringify
# => <div title="&quot;x&quot;">a &lt; b</div>
```

Use `raw { }` to emit trusted markup verbatim (never pass user input to it):

```ruby
UI { div { raw { '<em>trusted</em>' } } }.stringify
# => <div><em>trusted</em></div>
```

`Rubui.escape_html(value)` is also available directly.

### Custom elements

Subclass `Rubui::Element` and implement `render` to return another element:

```ruby
class Card < Rubui::Element
  def render
    PrimitiveElement.new('div', { 'class' => 'card' }, *children)
  end
end

Card.new({}, TextElement.new('hi')).stringify
# => <div class="card">hi</div>
```

### Running the tests

    $ rake test

## Contributing

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Added some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
