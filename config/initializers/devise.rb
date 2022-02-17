SpreeSocial::OAUTH_PROVIDERS.each do |provider|
  SpreeSocial.init_provider(provider[1])
end


# Ensure our environment is bootstrapped with a facebook connect app
if ActiveRecord::Base.connection.data_source_exists? 'spree_authentication_methods'
  Spree::AuthenticationMethod.where(environment: Rails.env, provider: 'google_oauth2').first_or_create do |auth_method|
    auth_method.api_key = ENV['140502616872-78tdvp6t5i7k9eopih4rli9d2jkul8r6.apps.googleusercontent.com']
    auth_method.api_secret = ENV['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']
    auth_method.active = true
  end
end

OmniAuth.config.logger = Logger.new(STDOUT)
OmniAuth.logger.progname = 'omniauth'

OmniAuth.config.on_failure = proc do |env|
  env['devise.mapping'] = Devise.mappings[Spree.user_class.table_name.singularize.to_sym]
  controller_name  = ActiveSupport::Inflector.camelize(env['devise.mapping'].controllers[:omniauth_callbacks])
  controller_klass = ActiveSupport::Inflector.constantize("#{controller_name}Controller")
  controller_klass.action(:failure).call(env)
end

Devise.setup do |config|
  config.router_name = :spree
end
