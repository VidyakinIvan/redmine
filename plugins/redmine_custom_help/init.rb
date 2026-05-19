Redmine::Plugin.register :redmine_custom_help do
  name 'Custom Help Plugin'
  author 'Ivan Vidyakin'
  description 'Replace default Help with a local wiki page'
  version '0.0.1'
  
  delete_menu_item :top_menu, :help

  menu :top_menu, :custom_help_link, 
       { :controller => 'projects', :action => 'show', :project_id => 'help'},
       :caption => 'Помощь',
       :last => true
end