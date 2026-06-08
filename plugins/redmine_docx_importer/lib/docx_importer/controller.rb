require 'csv'
require File.join(Rails.root, 'plugins', 'docx_importer', 'lib', 'docx_importer', 'parser')

class DocxImporterController < ApplicationController
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
    number_to_issue = {}

    CSV.parse(csv_string, headers: true, col_sep: ';') do |row|
      next if row['Тема задачи'].blank?

      issue = Issue.new(
        project: @project,
        tracker: @project.trackers.first,
        author: User.current,
        subject: row['Тема задачи'],
        description: row['Описание']
      )

      if issue.save
        count += 1
        number_to_issue[row['Номер раздела']] = issue.id
      end
    end

    CSV.parse(csv_string, headers: true, col_sep: ';') do |row|
      parent_number = row['Родительский раздел']
      next if parent_number.blank?

      issue_id = number_to_issue[row['Номер раздела']]
      parent_id = number_to_issue[parent_number]

      if issue_id && parent_id
        issue = Issue.find(issue_id)
        issue.parent_issue_id = parent_id
        issue.save
      end
    end

    count
  end
end