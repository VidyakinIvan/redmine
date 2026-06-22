Redmine::Plugin.register :redmine_login_redirect do
  name 'Custom Login Redirect plugin'
  author 'Ivan Vidyakin'
  description 'Redirects users to the home page after login'
  version '1.0.0'
  url 'https://github.com/VidyakinIvan/redmine/tree/master/plugins/redmine_login_redirect'
  author_url 'mailto:deadmazay123@mail.ru'
end

Rails.application.config.to_prepare do
  require_dependency 'account_controller'
  AccountController.class_eval do
    def successful_authentication_with_redirect(user)
      call_hook(:controller_account_success_authentication_after, { :user => user })
      redirect_to home_url
    end
    alias_method :successful_authentication, :successful_authentication_with_redirect
  end
end