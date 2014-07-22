# encoding: utf-8

module RuboCop
  module Cop
    module RSpec
      # Do not use should when describing your tests.
      # see: http://betterspecs.org/#should
      #
      # @example
      #   # bad
      #   it 'should find nothing' do
      #   end
      #
      #   # good
      #   it 'finds nothing' do
      #   end
      class ExampleWording < Cop
        MSG = 'Do not use should when describing your tests.'

        def on_block(node)
          method, _, _ = *node
          _, method_name, *args = *method

          return unless method_name == :it

          arguments = *(args.first)
          message = arguments.first.to_s
          return unless message.start_with?('should')

          arg1 = args.first.loc.expression
          message = Parser::Source::Range
            .new(arg1.source_buffer, arg1.begin_pos + 1, arg1.end_pos - 1)

          add_offense(message, message, MSG)
        end

        # the autocorrect is experimental - use with care!
        # there is no check if the second word (after the should) is a
        # verb and maybe finding the correct simple present needs
        # adaption
        def autocorrect(range)
          @corrections << lambda do |corrector|
            corrector.replace(range, corrected_message(range))
          end
        end

        def corrected_message(range)
          range.source.split(' ').tap do |words|
            words.shift
            words[0] = simple_present(words[0])
          end.join(' ')
        end

        def simple_present(word)
          return special_case(word) if special_case(word)

          # ends with o s x ch sh or ss
          if %w(o s x]).include?(word[-1]) ||
            %w(ch sh ss]).include?(word[-2..-1])
            return "#{word}es"
          end

          # ends with y
          if word[-1] == 'y' && !%w(a u i o e).include?(word[-2])
            return "#{word[0..-2]}ies"
          end

          "#{word}s"
        end

        private

        def special_case(word)
          {
            'be' => 'is',
            'have' => 'has',
            'not' => 'does not'
          }[word]
        end
      end
    end
  end
end
