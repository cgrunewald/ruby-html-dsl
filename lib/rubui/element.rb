module Rubui
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
          s << " #{k}=\"#{v}\""
        end
      end

      if @children.nil? || children.size == 0
        s << "/>"
      else
        s << ">"
        @children.each do |child|
          s << (child.is_a?(String) ? child : child.stringify)
        end
        s << "</#{@name}>"
      end
    end

    attr_reader :name, :attributes
    attr_accessor :children
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
      @children.each { |child| str << child.stringify }
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
      @text
    end
    attr_reader :text
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