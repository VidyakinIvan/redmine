require 'csv'
require File.join(Rails.root, 'plugins', 'redmine_docx_importer', 'lib', 'docx_importer', 'parser')

class DocxImportController < ApplicationController
  before_action :find_project, :authorize

  def upload
    file = params[:file]
    if file.nil? || !file.original_filename.end_with?('.docx')
      flash[:error] = 'Пожалуйста, загрузите файл .docx'
      redirect_to project_issues_path(@project)
      return
    end

    import_dir = File.join(Rails.root, 'tmp', 'docx_import')
    FileUtils.mkdir_p(import_dir)
    docx_path = File.join(import_dir, "#{Time.now.to_i}_#{file.original_filename}")
    File.open(docx_path, 'wb') { |f| f.write(file.read) }

    parser = DocxParser.new(docx_path)
    csv_string = parser.parse

    issues_created = import_from_csv(csv_string)

    flash[:notice] = "Создано задач: #{issues_created}"
    redirect_to project_issues_path(@project)
  rescue => e
    flash[:error] = "Ошибка: #{e.message}"
    redirect_to project_issues_path(@project)
  end

  private

  def find_project
    @project = Project.find(params[:project_id])
  end

  def import_from_csv(csv_string)
    count = 0

    CSV.parse(csv_string, headers: true, col_sep: ';') do |row|
      subject = row['Тема']
      next if subject.blank?

      description = row['Описание'] || ''
      status_name = row['Статус'] || 'Бэклог'
      tracker_name = row['Трекер'] || 'Входящий поток'
      priority_name = row['Приоритет'] || 'Важная'

      status = IssueStatus.find_by(name: status_name)
      tracker = Tracker.find_by(name: tracker_name)
      priority = IssuePriority.find_by(name: priority_name)

      status ||= IssueStatus.default
      tracker ||= @project.trackers.first
      priority ||= IssuePriority.default

      issue = Issue.new(
        project: @project,
        tracker: tracker,
        author: User.current,
        status: status,
        priority: priority,
        subject: subject,
        description: description
      )

      if issue.save
        count += 1
      else
        Rails.logger.error "DOCX Import: Failed to create issue '#{subject}': #{issue.errors.full_messages}"
      end
    end

    count
  end
end