module RailsAndSolid
  module Helper
    class Result
      def initialize(controller)
        @controller = controller
      end

      def redirect_to(where = nil)
        if where
          @controller.redirect_to @controller.send("#{where.to_s}_path")
        else
          RedirectTo.new(@controller)
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
  end
end