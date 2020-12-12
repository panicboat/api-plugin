class HttpRequestError < ApplicationError
  def status
    Rack::Utils::SYMBOL_TO_STATUS_CODE[:bad_gateway]
  end
end
