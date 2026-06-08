Redmine::Plugin.register :redmine_docx_importer do
  name 'DOCX Importer Plugin'
  author 'Ivan Vidyakin'
  description 'Import specification from Word into Redmine issues'
  version '0.0.2'
end

require_dependency 'docx_importer/hooks'
require_dependency 'docx_importer/controller'