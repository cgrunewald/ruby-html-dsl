require 'cgi'

module Rubui
  # Escapes &, <, >, " and ' so that arbitrary values can be safely embedded
  # in HTML text content and double-quoted attribute values.
  def self.escape_html(value)
    CGI.escapeHTML(value.to_s)
  end

  # Stringifies a child node. Bare strings (e.g. returned from a builder
  # block) are treated as text and escaped.
  def self.stringify_child(child)
    child.is_a?(String) ? escape_html(child) : child.stringify
  end

  class AbstractElement
    protected
    def validate
      false
    end

    public
    def stringify
      nil
    end
  end

  class BaseElement < AbstractElement
    def initialize(name, attributes)
      @name = name
      @attributes = attributes || {}
    end

    attr_reader :name, :attributes
    attr_accessor :children

    def add_attribute key, value
      @attributes[key] = value
    end

    def add_attributes attributes
      attributes.each { |key, value| add_attribute key, value }
    end

    def remove_attribute attribute
      @attributes.delete attribute
    end

    def remove_attributes attributes
      attributes.each { |key| remove_attribute key }
    end
  end

  class PrimitiveElement < BaseElement
    def initialize(name, attributes = {}, *children)
      super(name, attributes)
      @children = children || []
    end

    def validate
      bad_child = @children.find do |child|
        not child.validate
      end

      !@name.nil? && bad_child.nil?
    end

    def stringify
      s = "<#{@name}"
      if not @attributes.nil?
        @attributes.each do |k,v|
          s << " #{k}=\"#{Rubui.escape_html(v)}\""
        end
      end

      if @children.nil? || children.size == 0
        s << "/>"
      else
        s << ">"
        @children.each do |child|
          s << Rubui.stringify_child(child)
        end
        s << "</#{@name}>"
      end
    end

    attr_reader :name, :attributes
    attr_accessor :children
  end

  # A void element (br, img, input, ...) can never have children and is
  # always rendered self-closing, e.g. <br/> or <img src="a.png"/>.
  class VoidElement < PrimitiveElement
    TAGS = %w[area base br col embed hr img input link meta param source track wbr].freeze

    def self.void?(name)
      TAGS.include?(name.to_s)
    end

    def validate
      super && (@children.nil? || @children.empty?)
    end

    def stringify
      unless @children.nil? || @children.empty?
        raise ArgumentError, "<#{@name}> is a void element and cannot have children"
      end
      super
    end
  end

  class FragElement < BaseElement
    def initialize
      super 'frag', nil
    end

    def validate
      true
    end

    def stringify
      str = ''
      @children.each { |child| str << Rubui.stringify_child(child) }
      str
    end
  end

  class TextElement < AbstractElement
    def initialize(text)
      @text = text
    end

    def validate
      !@text.nil? && @text.is_a?(String)
    end

    def stringify
      Rubui.escape_html(@text)
    end
    attr_reader :text
  end

  # Text that is emitted verbatim, without HTML escaping. Only use this for
  # trusted markup.
  class RawElement < TextElement
    def stringify
      @text
    end
  end

  class Element < BaseElement

    def initialize(attributes = {}, *children)
      @attributes = attributes
      @children = children || []
    end
    
    attr_reader :attributes
    attr_accessor :children

    # metaclass for specification of attributes and children
    class << self
      def attributes(*args)
        @@attributes = args
      end
    end

    def validate
      true
    end

    def render
      raise Exception.new("Must override render method")
    end

    protected :render

    def stringify
      element = render
      if not element.is_a?(BaseElement)
        raise Exception.new("Rendered element is not a BaseElement")
      end
      if not element.validate
        raise Exception.new("Rendered element is not valid")
      end
      element.stringify
    end
  end
end