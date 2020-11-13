module Panicboat
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true

    attribute :limit,   virtual: true
    attribute :offset,  virtual: true

    scope :paging, ->(limit, offset) do
      limit(limit).offset(offset) if limit.present? && offset.present?
    end
  end
end
