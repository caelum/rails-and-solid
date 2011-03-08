module RailsAndSolid
  
  autoload :Helper, 'rails-and-solid/helper'
  autoload :TrickHim, 'rails-and-solid/trick_him'
  autoload :Handler, 'rails-and-solid/handler'

  # Shortcut to hack rails.
  def self.pimp(what)
    eval "class #{what.to_s.camelize}Controller < ApplicationController; end"
  end

end
