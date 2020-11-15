module Panicboat
  # TODO: Inheritance ActionController::API
  class ApplicationController < ActionController::Base
    protect_from_forgery
    skip_before_action :verify_authenticity_token
    around_action :intercept

    private

    def intercept
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
      ctx.merge!({ headers: request.headers })
      ctx.merge!({ sessions: { 'x-pnb-oidc-accesstoken': token, 'x-pnb-oidc-data': data } })
      ctx.merge!({ current_user: 'iiiiiii' })
    end
  end
end
