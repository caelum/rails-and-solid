module RailsAndSolid
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
    KEYS["redirect_to"] = Helper::RedirectTo
    KEYS["result"] = Result

    def provide(p)
      name = p.to_s
      provider = PROVIDERS.find do |f|
        f.handles?(self, name)
      end
      provider ? provider.extract(self, name) : nil
    end
  end
end