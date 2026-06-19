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

    mode = params[:import_mode] || 'cards'
    issues_created = import_from_csv(csv_string, mode)
	
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

  def import_from_csv(csv_string, mode)
    if mode == 'checklist'
      import_as_checklists(csv_string)
    else
      import_as_cards(csv_string)
    end
  end

  def import_as_cards(csv_string)
    count = 0

    CSV.parse(csv_string, headers: true, col_sep: ';') do |row|
      subject = row['Тема']
      next if subject.blank?

      status_name = row['Статус'] || 'Бэклог'
      tracker_name = row['Трекер'] || 'Входящий поток'
      priority_name = row['Приоритет'] || 'Важная'

      status = IssueStatus.find_by(name: status_name) || IssueStatus.default
      tracker = Tracker.find_by(name: tracker_name) || @project.trackers.first
      priority = IssuePriority.find_by(name: priority_name) || IssuePriority.default

      issue = Issue.new(
        project: @project,
        tracker: tracker,
        author: User.current,
        status: status,
        priority: priority,
        subject: subject,
        description: row['Описание'] || ''
      )

      count += 1 if issue.save
    end

    count
  end
  
def import_as_checklists(csv_string)
  count = 0
  groups = {}

  CSV.parse(csv_string, headers: true, col_sep: ';') do |row|
    subject = row['Тема']
    next if subject.blank?

    # Извлекаем номер раздела из начала строки (например, "6.4.1 Описание" -> "6.4.1")
    number_match = subject.match(/^(\d+(?:\.\d+)*)/)
    next unless number_match
    
    number = number_match[1]
    dots = number.count('.')

    if dots == 1
      # Уровень 2 — родительская задача
      groups[number] ||= { parent: row, children: [] }
      groups[number][:parent] = row
    elsif dots == 2
      # Уровень 3 — дочерний пункт
      parent_key = number.split('.')[0..1].join('.')  # "6.4.1" -> "6.4"
      groups[parent_key] ||= { parent: nil, children: [] }
      groups[parent_key][:children] << row
    end
  end

  # Создаём задачи
  groups.each do |parent_key, data|
    parent_row = data[:parent]
    children = data[:children]
    
    next unless parent_row

    subject = parent_row['Тема']
    description = parent_row['Описание'] || ''
    
    status_name = parent_row['Статус'] || 'Бэклог'
    tracker_name = parent_row['Трекер'] || 'Входящий поток'
    priority_name = parent_row['Приоритет'] || 'Важная'

    status = IssueStatus.find_by(name: status_name) || IssueStatus.default
    tracker = Tracker.find_by(name: tracker_name) || @project.trackers.first
    priority = IssuePriority.find_by(name: priority_name) || IssuePriority.default

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
      children.each do |child_row|
        child_subject = child_row['Тема']
        checklist_item = ChecklistItem.new(
          issue: issue,
          subject: child_subject,
          is_done: false
        )
        checklist_item.save
      end
      count += 1
    end
  end

  count
end
  
  
end