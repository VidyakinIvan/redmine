Redmine::Plugin.register :redmine_custom_help do
  name 'Custom Help plugin'
  author 'Ivan Vidyakin'
  description 'Replace default Help with a local wiki page'
  version '1.0.0'
  url 'https://github.com/VidyakinIvan/redmine/tree/master/plugins/redmine_custom_help'
  author_url 'mailto:deadmazay123@mail.ru'
  
  delete_menu_item :top_menu, :help

  menu :top_menu, :custom_help_link, 
       { :controller => 'projects', :action => 'show', :id => 'help'},
       :caption => 'Помощь',
       :last => true
end