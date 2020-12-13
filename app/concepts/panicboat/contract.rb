class Panicboat::Contract < Reform::Form
  property :limit,    virtual: true
  property :offset,   virtual: true
  property :order,    virtual: true

  validates :limit,   numericality: true, allow_blank: true
  validates :offset,  numericality: true, allow_blank: true

  FORMAT_UUID=/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/i
  FORMAT_EMAIL=/\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  FORMAT_URL=/\A#{URI::regexp(%w(http https))}\z/
end
