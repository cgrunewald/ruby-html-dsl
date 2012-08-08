require 'rubui/element'

module Rubui
  class Builder
    def initialize
      @element_stack = [Array.new]
    end

    protected
    def self.create_element(name)
      class_eval <<-STR
        def #{name} attributes = {}, &block
          element '#{name}', attributes, &block
        end
      STR
    end

    def build element, &block
      @element_stack.last.push element

      # push a new array on the stack (representing this elements children)
      # process the block, passing this object as the implicit context
      @element_stack.push Array.new

      ret = instance_eval &block if block_given?

      # take the last element and pop it off the stack
      # this element contains the children processed in the block
      # these are the children of the element created by this particular call
      children = @element_stack.pop
      if ret && !ret.nil?
        children.push ret # the block may return a string an element explicitly
      end
      element.children= children

      # If this isn't the last call in the recursion, return nil so the
      # element isn't double added (see above)
      if @element_stack.size > 1
        nil
      else
        @element_stack.last.pop
      end
    end

    def element(name, attributes = {}, &block)
      # append element to the last array on the stack
      element = PrimitiveElement.new name, attributes
      build element, &block
    end

    public
    def text
      TextElement.new(yield)
    end

    def frag &block
      element = FragElement.new
      build element, &block
    end

    create_element 'div'
    create_element 'span'
    create_element 'p'
    create_element 'li'
    create_element 'ol'
    create_element 'ul'
    create_element 'dd'
    create_element 'dl'
    create_element 'dt'
  end

  def UI &block
    builder = Builder.new
    builder.frag &block if block_given?
  end
end