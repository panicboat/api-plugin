class Panicboat::Operation < Trailblazer::Operation
  def contract(ctx)
    ctx[:"contract.default"]
  end

  def permit!(ctx, **)
    raise NotImplementedError
  end

  def uuid!(ctx, model:, **)
    model.id = Identity.uuid(model.class)
  end

  def invalid_params!(ctx, **)
    raise ::InvalidParameters, ["Parameters #{I18n.t('errors.messages.invalid')}"] if ctx[:"contract.default"].blank?

    raise ::InvalidParameters, ctx[:"contract.default"].errors.full_messages
  end
end
