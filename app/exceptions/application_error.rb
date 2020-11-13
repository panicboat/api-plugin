class ApplicationError < StandardError
  attr_reader :status

  def initialize(messages)
    @status = status()
    super(messages)
  end

  private

    def status
      raise NotImplementedError
    end
end
