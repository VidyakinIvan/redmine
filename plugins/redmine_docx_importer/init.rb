Redmine::Plugin.register :redmine_docx_importer do
  name 'DOCX Importer plugin'
  author 'Ivan Vidyakin'
  description 'Import specification from Word into Redmine issues'
  version '0.9.0'
  url 'https://github.com/VidyakinIvan/redmine/tree/master/plugins/redmine_docx_importer'
  author_url 'mailto:deadmazay123@mail.ru'
  
  permission :docx_import, { docx_import: [:upload] }, public: true
end

Rails.autoloaders.main.ignore("#{__dir__}/lib")
Rails.autoloaders.main.ignore("#{__dir__}/app")

require_relative 'lib/docx_importer/hooks'
require_relative 'lib/docx_importer/docx_import_controller'