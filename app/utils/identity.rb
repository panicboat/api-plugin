class Identity
  def self.uuid(clazz)
    loop do
      uuid = SecureRandom.uuid
      break uuid unless clazz.exists?({ id: uuid })
    end
  end
end
