Redmine::Plugin.register :redmine_hiding_activity do
  name 'Hide Activity Tab'
  author 'Ivan VIdyakin'
  description 'Removes Activity tab from specific projects'
  version '0.0.2'
end

Redmine::MenuManager.map :project_menu do |menu|
  menu.find(:activity).instance_variable_set(:@condition, 
    Proc.new { |project| project.identifier != 'help' }
  )
  
end