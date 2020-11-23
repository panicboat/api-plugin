module Panicboat
  class AbstractController < ApplicationController
    def _userdata(data, headers)
      return nil if data.blank?

      req = ::RequestProvider.new(ENV['HTTP_IAM_URL'], headers)
      users = req.get('/users', { email: data.first['email'] }).Users
      return nil if users.blank?

      users.first
    end
  end
end
