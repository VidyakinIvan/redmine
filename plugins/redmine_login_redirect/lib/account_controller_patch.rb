require_dependency 'account_controller'

module AccountControllerPatch
  def self.included(base)
    base.send(:include, InstanceMethods)
    base.class_eval do
      alias_method :original_successful_authentication, :successful_authentication
      alias_method :successful_authentication, :patched_successful_authentication
    end
  end

  module InstanceMethods
    def patched_successful_authentication(user)
      call_hook(:controller_account_success_authentication_after, {:user => user})
      redirect_to home_url
    end
  end
end

AccountController.send(:include, AccountControllerPatch) unless AccountController.included_modules.include?(AccountControllerPatch)