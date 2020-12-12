module Panicboat
  # TODO: Inheritance ActionController::API
  class ApplicationController < ActionController::Base
    protect_from_forgery
    skip_before_action :verify_authenticity_token
    around_action :intercept

    private

    def intercept
      # request.headers.sort.map { |k, v| Rails.logger.debug "#{k}:#{v}" }
      ActiveRecord::Base.transaction do
        yield
      rescue StandardError => e
        ActiveRecord::Rollback
        status = e.is_a?(ApplicationError) ? e.status : Rack::Utils::SYMBOL_TO_STATUS_CODE[:internal_server_error]
        messages = JSON.parse(e.message) rescue e.message
        render status: status, json: { status: status, type: e.class.name, messages: messages }
      end
    end

    def represent(clazz, ctx, **)
      clazz.new(ctx[:model])
    end
  end
end
