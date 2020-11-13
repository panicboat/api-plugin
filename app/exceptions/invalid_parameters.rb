class InvalidParameters < ApplicationError
  def status
    Rack::Utils::SYMBOL_TO_STATUS_CODE[:unprocessable_entity]
  end
end
