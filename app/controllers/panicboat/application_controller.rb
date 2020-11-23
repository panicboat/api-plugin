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
        status = e.kind_of?(ApplicationError) ? e.status : Rack::Utils::SYMBOL_TO_STATUS_CODE[:internal_server_error]
        render status: status, json: { status: status, type: e.class.name, messages: JSON.parse(e.message) }
      end
    end

    def represent(clazz, ctx, **)
      clazz.new(ctx[:model])
    end

    def _run_options(ctx)
      headers = RequestHeader.new(request.headers)
      session = SessionManager.new(request.headers)
      token = session.token(RequestHeader::ACCESS_TOKEN)
      data = session.data(RequestHeader::USER_CLAIMS)
      ctx.merge!({ headers: headers })
      ctx.merge!({ action: "#{ENV['MY_SERVICE_NAME']}:#{_action}" })
      ctx.merge!({ sessions: { "#{RequestHeader::ACCESS_TOKEN}": token, "#{RequestHeader::USER_CLAIMS}": data } })
      ctx.merge!({ current_user: _userdata(data, headers) })
    end

    def _action
      controller = request.controller_class.to_s.gsub(/Controller$/, '').singularize
      action = request.path_parameters[:action]
      case action
      when 'destroy' then "Delete#{controller.capitalize}"
      when 'index' then "List#{controller.capitalize}"
      when 'show' then "Get#{controller.capitalize}"
      else "#{action.capitalize}#{controller.capitalize}"
      end
    end

    def _userdata(data, headers)
      raise NotImplementedError
    end
  end
end
