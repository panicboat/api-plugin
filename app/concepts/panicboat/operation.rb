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

  def filter(ctx, model, key)
    condition = model.where('1=1')
    ctx[:permissions].each do |permission|
      condition = _filter(permission, model, condition, key) if permission.effect == 'allow'
    end
    ctx[:permissions].each do |permission|
      condition = _filter(permission, model, condition, key) if permission.effect == 'deny'
    end
    condition
  end

  private

  def _filter(permission, model, condition, key)
    permission.prn.each do |prn|
      search = prn.gsub(/\*/, '%')
      sql = "CONCAT(\"prn:panicboat:#{ENV['AWS_ECS_CLUSTER_NAME']}:#{ENV['AWS_ECS_SERVICE_NAME']}:#{model.name.downcase}/\", #{key}) LIKE ?"
      condition = if permission.effect == 'allow'
                    condition.or(model.where(sql, search))
                  else
                    condition.where.not(sql, search)
                  end
    end
    condition
  end
end
