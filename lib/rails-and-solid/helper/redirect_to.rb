module RailsAndSolid
  module Helper
    class RedirectTo
      def initialize(controller)
        @controller = controller
      end
      def method_missing(path)
        @controller.redirect_to @controller.send(path)
      end
    end
  end
end