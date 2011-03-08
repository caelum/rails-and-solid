module RailsAndSolid
  module Handler
    class Load
      def extract(controller, name)
        var = type_for(name)
        loaded = var.camelize.constantize.find(controller.params[:id])
        controller.send :instance_variable_set ,"@#{var}", loaded
        return loaded
      end
      def type_for(name)
        name[7..-1]
      end
      def handles?(controller, name)
        name[0..6]=="loaded_" && defined?(type_for(name).camelize.constantize)
      end
    end
  end
end