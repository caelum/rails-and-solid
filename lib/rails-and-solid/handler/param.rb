module RailsAndSolid
  module Handler
    class Param
      def extract(controller, name)
        controller.params[name]
      end
      def handles?(controller, name)
        controller.params[name]
      end
    end
  end
end