# encoding: utf-8

module Rubocop
  module Cop
    # If the first argument of describe is a class, the class is exposed to
    # each example via described_class - this should be used instead of
    # repeating the class.
    #
    # @example
    #   # bad
    #   describe MyClass do
    #     subject { MyClass.do_something }
    #   end
    #
    #   # good
    #   describe MyClass do
    #     subject { described_class.do_something }
    #   end
    #
    #   describe MyModule do
    #     include described_class
    #   end
    class RSpecDescribedClass < Cop
      include TopLevelDescribe

      MESSAGE = 'Use `described_class` for tested class / module'

      def on_block(node)
        method, _args, body = *node
        return unless top_level_describe?(method)

        _receiver, method_name, object = *method
        return unless method_name == :describe
        return unless object && object.type == :const

        inspect_children(body, object)
      end

      private

      def inspect_children(node, object)
        return unless node.is_a? Parser::AST::Node
        return if node.type == :const

        node.children.each do |child|
          if child == object
            add_offense(child, :expression, MESSAGE)
            break
          end
          inspect_children(child, object)
        end
      end
    end
  end
end
