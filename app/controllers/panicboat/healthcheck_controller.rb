module Panicboat
  class HealthcheckController < ::ApplicationController
    def index
      { status: Rack::Utils::SYMBOL_TO_STATUS_CODE[:ok] }
    end
  end
end
