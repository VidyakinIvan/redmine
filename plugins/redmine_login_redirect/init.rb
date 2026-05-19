Redmine::Plugin.register :redmine_login_redirect do
  name 'Custom Login Redirect'
  author 'Ivan Vidyakin'
  description 'Redirect users to the home page after login'
  version '0.0.1'

  require_dependency 'account_controller_patch'
end