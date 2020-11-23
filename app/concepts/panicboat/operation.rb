class Panicboat::Operation < Trailblazer::Operation
  def contract(ctx)
    ctx[:"contract.default"]
  end

  def permit!(ctx, **)
    return [] if ctx[:current_user].blank?

    req = ::RequestProvider.new(ENV['HTTP_IAM_URL'], ctx[:headers])
    @permissions = req.get("/permissions/#{ctx[:action]}", {}).Permissions

    raise ::InvalidPermissions, ["Permissions #{I18n.t('errors.messages.invalid')}"] if permissions.blank?
  end

  def uuid!(ctx, model:, **)
    model.id = Identity.uuid(model.class)
  end

  def invalid_params!(ctx, **)
    raise ::InvalidParameters, ["Parameters #{I18n.t('errors.messages.invalid')}"] if ctx[:"contract.default"].blank?

    raise ::InvalidParameters, ctx[:"contract.default"].errors.full_messages
  end

  private

  attr_reader :permissions
end
