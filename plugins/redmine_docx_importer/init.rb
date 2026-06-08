Redmine::Plugin.register :redmine_docx_importer do
  name 'DOCX Importer Plugin'
  author 'Ivan Vidyakin'
  description 'Import specification from Word into Redmine issues'
  version '0.0.2'
end

plugin_dir = File.dirname(__FILE__)
require File.join(plugin_dir, 'lib', 'docx_importer', 'hooks')
require File.join(plugin_dir, 'lib', 'docx_importer', 'docx_import_controller')