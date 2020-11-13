module Panicboat
  class Engine < ::Rails::Engine
    isolate_namespace Panicboat
    config.generators.api_only = true
  end
end
