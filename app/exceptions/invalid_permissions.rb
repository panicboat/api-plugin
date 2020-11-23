class InvalidPermissions < ApplicationError
  def status
    Rack::Utils::SYMBOL_TO_STATUS_CODE[:forbidden]
  end
end
