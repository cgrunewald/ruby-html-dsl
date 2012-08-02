module Rubui
  class BaseElement
    def validate
      false
    end

    def stringify
      nil
    end
  end

  class PrimitiveElement < BaseElement
    def initialize(name, attributes = {}, *children)
      @children = children || []
      @name = name
      @attributes = attributes
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
          s << child.stringify
        end
        s << "</#{@name}>"
      end
    end

    attr_reader :name, :attributes, :children
  end

  class TextElement < BaseElement
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
    
    attr_reader :children, :attributes

    # metaclass for specification of attributes and children
    class << self
      def attributes(*args)
        @@attributes = args
      end
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
      element.stringify
    end
  end
end