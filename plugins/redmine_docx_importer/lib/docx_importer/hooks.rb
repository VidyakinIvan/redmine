class DocxImporterHooks < Redmine::Hook::ViewListener
  def view_issues_index_bottom(context = {})
    project = context[:project]
    controller = context[:controller]
	
	return unless project.present?
    controller.send(:render_to_string, {
      partial: 'docx_importer/upload_form',
      locals: { project: project }
    })
  end
end