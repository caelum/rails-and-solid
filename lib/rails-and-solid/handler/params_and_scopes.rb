module RailsAndSolid
  module Handler
    class ParamsAndScopes
      def extract(controller, var)
        if var=="params"
          controller.params
        elsif var=="session"
          controller.session
        else
          controller.flash
        end
      end
      SUPPORTED = ["params", "session", "flash"]
      def handles?(controller, name)
        SUPPORTED.include? name
      end
    end
  end
end