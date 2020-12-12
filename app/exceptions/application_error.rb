class ApplicationError < StandardError
  def initialize(messages)
    @status = status
    super(messages.to_json)
  end

  def status
    raise NotImplementedError
  end
end
