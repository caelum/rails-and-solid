module RailsAndSolid

  class JsonHelper
    def initialize(controller)
      @controller = controller
    end
    def message(x)
      @controller.render :json => {'message' => x}
    end
  end

  class RedirectToHelper
    def initialize(controller)
      @controller = controller
    end
    def method_missing(path)
      @controller.redirect_to @controller.send(path)
    end
  end

  class ResultHelper

    def initialize(controller)
      @controller = controller
    end

    def redirect_to(where = nil)
      if where
        @controller.redirect_to @controller.send("#{where.to_s}_path")
      else
        RedirectToHelper.new(@controller)
      end
    end

    def render(*args, &block)
      @controller.render *args, &block
    end

    def text(content, options = {}, &block)
      options[:text] = content
      @controller.render(options, &block)
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

  module TrickHim

    def method_for_action(method)
      # TRICKing rails... no inheritance support
      method
    end

    def class_exists?(class_name, method)
      # TODO cache is only for production (no reload)
      @exists ||= {}
      return @exists[class_name] if @exists.key?(class_name)

      # TODO solution1
      klass = Module.const_get(class_name)
      self.class.send :define_method, method do
        # rails inheritance on my way (ret = super(sym)), once again...
      end
      return @exists[class_name] = klass.is_a?(Class)
    rescue NameError
      # exceptions and traces are expensive.
      @exists[class_name] = false
      return false
    end

    # TODO solution 2 is to define it to false, not overriden
    # when you invoke hack, you say... to hell with inheritance
    # def class_exists?(t)
      # false
    # end

    def send_action(sym)
      type = self.class.name
      type = type[0..type.size-4]
      if (class_exists?(type, sym))
        type = type.constantize
        control = di_instantiate(type)
        params = extract_params_for(control.method(sym))
        ret = control.send sym, *params
        control.instance_variables.each do |x|
          value = control.instance_variable_get x
          instance_variable_set x, value
        end
        super(sym)
      else
        params = extract_params_for(method(sym))
        super(sym, *params)
      end
    end

    def di_instantiate(type)
      type.new
    end

    private
    def extract_params_for(method)
      types = method.parameters
      if has_parameters(types)
        provide_instances_for(types)
      else
        []
      end
    end

    def has_parameters(types)
      types.size!=0 && types[0]!=[:rest]
    end

    def provide_instances_for(params)
      params.collect do |param|
        provide(param[1])
      end
    end

    KEYS = KeyProvider.new
    PROVIDERS = [KEYS, SessionLocator.new, Load.new, Instantiate.new, ParamsAndScopes.new, Param.new]

    KEYS["json"] = JsonHelper
    KEYS["redirect_to"] = RedirectToHelper
    KEYS["result"] = ResultHelper

    def provide(p)
      name = p.to_s
      provider = PROVIDERS.find do |f|
        f.handles?(self, name)
      end
      provider ? provider.extract(self, name) : nil
    end

  end

end
