Rails.application.routes.draw do
  post 'projects/:project_id/docx_import/upload', to: 'docx_import#upload', as: 'docx_import_upload'
end