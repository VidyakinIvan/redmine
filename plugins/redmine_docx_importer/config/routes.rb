Redmine::Plugin.find(:redmine_docx_importer).routes.draw do
  post 'docx_import/upload', to: 'docx_import#upload'
end