class RequestProvider
  def initialize(url, headers = {})
    @connection = ::Faraday.new(url: url) do |builder|
      builder.use Faraday::Request::UrlEncoded
      builder.use Faraday::Response::Logger
    end
    @headers = headers
  end

  def get(path, params, representer = nil)
    response = connection.get(path) do |req|
      ready_for_request(req, params)
    end
    represent(response, representer)
  end

  def post(path, params, representer = nil)
    response = connection.post(path) do |req|
      ready_for_request(req, params)
    end
    represent(response, representer)
  end

  def patch(path, params, representer = nil)
    response = connection.patch(path) do |req|
      ready_for_request(req, params)
    end
    represent(response, representer)
  end

  def delete(path, params, representer = nil)
    response = connection.delete(path) do |req|
      ready_for_request(req, params)
    end
    represent(response, representer)
  end

  private

  attr_accessor :connection, :headers

  def ready_for_request(req, params)
    headers.sort.map do |k, v|
      req.headers[k] = v
    end
    req.headers['Content-Type'] = 'application/json'
    req.body = params.to_json
  end

  def represent(response, clazz)
    model = OpenStruct.new(JSON.parse(response.body))
    if response.status != Rack::Utils::SYMBOL_TO_STATUS_CODE[:ok]
      Rails.logger.warn '===== HTTP REQUEST ERROR ====='
      Rails.logger.warn response.body
      model
    end
    clazz.present? ? OpenStruct.new(JSON.parse(clazz.new(model).to_json)) : model
  end
end
