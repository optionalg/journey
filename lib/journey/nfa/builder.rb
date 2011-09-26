require 'journey/nfa/transition_table'
require 'journey/nfa/generalized_table'

module Journey
  module NFA
    class Visitor < Visitors::Visitor
      def initialize tt
        @tt = tt
        @i  = -1
      end

      def visit_CAT node
        left  = visit node.left
        right = visit node.right

        @tt.merge left.last, right.first

        [left.first, right.last]
      end

      def visit_GROUP node
        from  = @i += 1
        left  = visit node.left
        to    = @i += 1

        @tt.accepting = to

        @tt[from, left.first] = nil
        @tt[left.last, to] = nil
        @tt[from, to] = nil

        [from, to]
      end

      def visit_OR node
        from  = @i += 1
        left  = visit node.left
        right = visit node.right
        to    = @i += 1

        @tt[from, left.first]  = nil
        @tt[from, right.first] = nil
        @tt[left.last, to]     = nil
        @tt[right.last, to]    = nil

        @tt.accepting = to

        [from, to]
      end

      def terminal node
        from_i = @i += 1 # new state
        to_i   = @i += 1 # new state

        @tt[from_i, to_i] = node
        @tt.accepting = to_i

        [from_i, to_i]
      end
    end

    class Builder
      def initialize ast
        @ast = ast
      end

      def transition_table
        tt = TransitionTable.new
        Visitor.new(tt).accept @ast
        tt
      end
    end
  end
end
