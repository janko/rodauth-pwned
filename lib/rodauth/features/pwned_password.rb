# frozen_string_literal: true

require "pwned"

module Rodauth
  Feature.define(:pwned_password, :PwnedPassword) do
    depends :login_password_requirements_base

    auth_value_method :password_allowed_pwned_count, 0
    translatable_method :password_pwned_message, "this password has previously appeared in a data breach and should never be used"
    auth_value_method :pwned_request_options, {}

    auth_methods(
      :password_pwned?,
      :pwned_count,
      :on_pwned_error,
    )

    def password_meets_requirements?(password)
      super && password_not_pwned?(password)
    end

    def password_pwned?(password)
      pwned_count(password) > password_allowed_pwned_count
    rescue Pwned::Error => error
      on_pwned_error(error)
      nil
    end

    def pwned_count(password)
      Pwned.pwned_count(password, pwned_request_options)
    end

    def post_configure
      super
      i18n_register File.expand_path("#{__dir__}/../../../locales") if features.include?(:i18n)
    end

    private

    def password_not_pwned?(password)
      return true unless password_pwned?(password)
      @password_requirement_message = password_pwned_message
      false
    end

    def on_pwned_error(error)
      # nothing by default
    end
  end
end
