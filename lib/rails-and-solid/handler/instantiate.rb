module RailsAndSolid
  module Handler
    class Instantiate
      def extract(controller, var)
        val = var.camelize.constantize.new(controller.params[p])
        controller.send :instance_variable_set ,"@#{var}", val
        return val
      end
      def handles?(controller, name)
        defined?(name.camelize.constantize)==true && name.camelize.constantize.is_a?(ActiveRecord::Base)
      end
    end
  end
end