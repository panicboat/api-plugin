class RequestHeader
  ACCESS_TOKEN = 'x-pnb-oidc-accesstoken'.freeze
  OIDC_IDENTITY = 'x-pnb-oidc-identity'.freeze
  USER_CLAIMS = 'x-pnb-oidc-data'.freeze

  def initialize(headers = {})
    @origin = headers
  end

  def keys
    [ACCESS_TOKEN, OIDC_IDENTITY, USER_CLAIMS]
  end

  def authorization
    headers = {}
    keys.each { |x| headers[x.to_sym] = origin[x.to_sym] }
    headers
  end

  private

  attr_accessor :origin
end
