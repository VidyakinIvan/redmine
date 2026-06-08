Redmine::Plugin.register :redmine_docx_importer do
  name 'DOCX Importer Plugin'
  author 'Your Company'
  description 'Import specification from Word into Redmine issues'
  version '0.0.3'
  
  permission :docx_import, { docx_import: [:upload] }, public: true
end

Rails.autoloaders.main.ignore("#{__dir__}/lib")
Rails.autoloaders.main.ignore("#{__dir__}/app")

require_relative 'lib/docx_importer/hooks'
require_relative 'lib/docx_importer/docx_import_controller'