class SessionManager
  def initialize(headers)
    @headers = headers
  end

  def data(key)
    return nil if headers[key].blank?

    decode(headers[key])
  end

  def token(key)
    return nil if headers[key].blank?

    decode(headers[key])
  end

  private

  attr_accessor :headers

  def decode(jwt)
    uri = "https://cognito-idp.#{ENV['AWS_DEFAULT_REGION']}.amazonaws.com/#{ENV['AWS_COGNITO_USERPOOL_ID']}/.well-known/jwks.json"
    response = ::Net::HTTP.get_response(::URI.parse(uri))
    jwks = ::JSON.parse(response.body)
    payload = ::JWT.decode(jwt, nil, false)
    return false if payload[0]['iss'] != "https://cognito-idp.#{ENV['AWS_DEFAULT_REGION']}.amazonaws.com/#{ENV['AWS_COGNITO_USERPOOL_ID']}"
    kid = payload[1]['kid']
    case payload[0]['token_use']
    when 'id' then
      modulus = bn(jwks['keys'][0]['n'])
      exponent = bn(jwks['keys'][0]['e'])
      sequence = ::OpenSSL::ASN1::Sequence.new([::OpenSSL::ASN1::Integer.new(modulus), ::OpenSSL::ASN1::Integer.new(exponent)])
      ::JWT.decode jwt, ::OpenSSL::PKey::RSA.new(sequence.to_der), true, algorithm: payload[1]['alg']
    when 'access' then
      return false if ::Time.zone.now.to_i > payload[0]['exp']
      payload
    end
  end

  def bn(n)
    n = n + '=' * (4 - n.size % 4) if n.size % 4 != 0
    decoded = ::Base64.urlsafe_decode64 n
    unpacked = decoded.unpack('H*').first
    ::OpenSSL::BN.new unpacked, 16
  end
end
