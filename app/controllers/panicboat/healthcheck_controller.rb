module Panicboat
  class HealthcheckController < ActionController::API
    def index
      render json: { status: Rack::Utils::SYMBOL_TO_STATUS_CODE[:ok] }
    end
  end
end
