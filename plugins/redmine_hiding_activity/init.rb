Redmine::Plugin.register :redmine_hiding_activity do
  name 'Hide Activity plugin'
  author 'Ivan VIdyakin'
  description 'Removes Activity tab from specific projects'
  version '1.0.0'
  url 'https://github.com/VidyakinIvan/redmine/tree/master/plugins/redmine_hiding_activity'
  author_url 'mailto:deadmazay123@mail.ru'
end

Redmine::MenuManager.map :project_menu do |menu|
  menu.find(:activity).instance_variable_set(:@condition, 
    Proc.new { |project| project.identifier != 'help' }
  )
  
end