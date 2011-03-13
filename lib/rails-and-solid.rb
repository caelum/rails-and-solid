module RailsAndSolid
  
  autoload :Helper, 'rails-and-solid/helper'
  autoload :TrickHim, 'rails-and-solid/trick_him'
  autoload :Handler, 'rails-and-solid/handler'

  # Shortcut to hack rails.
  def self.pimp(what)
    Object.module_eval "class #{what.to_s.camelize}Controller < ApplicationController; end"
  end

end

class ActionController::Base
  def self.solidify
    include RailsAndSolid::TrickHim
  end
end
