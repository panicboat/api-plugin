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
      session = SessionManager.new(request.headers)
      token = session.token('x-pnb-oidc-accesstoken')
      data = session.data('x-pnb-oidc-data')
      ctx.merge!({ request: request })
      ctx.merge!({ action: "#{ENV['MY_SERVICE_NAME']}:#{_action}" })
      ctx.merge!({ sessions: { 'x-pnb-oidc-accesstoken': token, 'x-pnb-oidc-data': data } })
      ctx.merge!({ current_user: _userdata(data) })
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

    def _userdata(data)
      raise NotImplementedError
    end
  end
end
