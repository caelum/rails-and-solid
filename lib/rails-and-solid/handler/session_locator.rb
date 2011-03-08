module RailsAndSolid
  module Handler
    class SessionLocator
      def extract(controller, var)
        controller.session[var]
      end
      def handles?(controller, name)
        controller.session[name]
      end
    end 
  end
end