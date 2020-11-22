class Panicboat::Representer < Representable::Decorator
  include Representable::JSON
  defaults render_nil: true
end
