module RailsAndSolid
  
  autoload :Helper, 'rails-and-solid/helper'
  autoload :TrickHim, 'rails-and-solid/trick_him'

  class JsonHelper
    def initialize(controller)
      @controller = controller
    end
    def message(x)
      @controller.render :json => {'message' => x}
    end
  end

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

  class Param
    def extract(controller, name)
      controller.params[name]
    end
    def handles?(controller, name)
      controller.params[name]
    end
  end

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

  class SessionLocator
    def extract(controller, var)
      controller.session[var]
    end
    def handles?(controller, name)
      controller.session[name]
    end
  end

  class KeyProvider
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
