class Panicboat::Operation < Trailblazer::Operation
  def uuid!(ctx, model:, **)
    model.id = Identity.uuid(model.class)
  end

  def invalid_params!(ctx, **)
    raise ::InvalidParameters, ["Parameters #{I18n.t('errors.messages.invalid')}"] if ctx[:"contract.default"].blank?

    raise ::InvalidParameters, ctx[:"contract.default"].errors.full_messages
  end

  def permit!(ctx, **)
    return [] if ctx[:current_user].blank?

    req = ::RequestProvider.new(ENV['HTTP_IAM_URL'], ctx[:headers])
    permissions = req.get("/permissions/#{ctx[:action]}", {}).Permissions
    raise ::InvalidPermissions, ["Permissions #{I18n.t('errors.messages.invalid')}"] if permissions.blank?

    ctx[:permissions] = permissions
  end

  def filter(ctx, resource, model, key)
    instance = model.where('1=1')
    ctx[:permissions].each do |permission|
      instance = _filter(permission, resource, model, instance, key)
    end
    instance
  end

  private

  def _filter(permission, resource, model, instance, key)
    permission.prn.each do |prn|
      search = prn.gsub(/\*/, '%')
      case permission.effect
      when 'allow'
        instance = instance.or(model.where("CONCAT(\"#{resource}/\", #{key}) LIKE ?", search))
      when 'deny'
        instance = instance.where.not("#{key} LIKE ?", search)
      end
    end
    instance
  end
end
