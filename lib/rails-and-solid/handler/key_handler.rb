module RailsAndSolid
  module Handler
    class KeyHandler
      def initialize
        @helpers = {}
      end
      def []=(name, who)
        @helpers[name] = who
      end
      def extract(controller, name)
        @helpers[name].new(controller)
      end
      def handles?(controller, name)
        @helpers[name]
      end
    end
  end
end