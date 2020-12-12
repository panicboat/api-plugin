module Panicboat
  class AbstractController < ApplicationController
    private

    def _run_options(ctx)
      headers = ::RequestHeader.new(request.headers)
      ctx.merge!({ headers: headers })
      ctx.merge!({ action: "#{ENV['AWS_ECS_SERVICE_NAME']}:#{_action}" })
      ctx.merge!({ current_user: _session(headers) })
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

    def _session(headers)
      return nil if headers.authorization[::RequestHeader::USER_CLAIMS].blank?

      req = ::RequestProvider.new(ENV['HTTP_IAM_URL'], headers)
      payload = req.get('/tokens', {}).Payload
      return nil if payload.claims.blank?

      users = req.get('/users', { email: payload.claims.first.email }).Users
      return nil if users.blank?

      users.first
    end
  end
end
