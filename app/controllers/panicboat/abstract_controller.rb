module Panicboat
  class AbstractController < ApplicationController
    def _userdata(data)
      return nil if data.blank?

      req = ::RequestProvider.new(ENV['HTTP_IAM_URL'], request.headers)
      users = req.get('/users', { email: data[0]['email'] }).Users
      return nil if users.blank?

      users[0]
    end
  end
end
