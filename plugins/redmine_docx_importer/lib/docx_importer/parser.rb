require 'docx'
require 'csv'
require 'nokogiri'

class DocxParser
  def initialize(file_path)
    @doc = Docx::Document.open(file_path)
  end

  def parse
    sections = extract_sections
    leaf_sections = filter_leaves(sections)
    generate_csv(leaf_sections)
  end

  private

  def extract_sections
    sections = []
    current_number = ""
    current_title = ""
    current_text_lines = []
    current_level = 0
    counters = [0, 0, 0]

    @doc.paragraphs.each do |para|
      level = get_heading_level(para)

      if level > 0
        if !current_number.empty?
          sections << {
            number: current_number,
            title: current_title,
            text: current_text_lines.join("\n").strip,
            level: current_level
          }
        end

        current_title = para.text.strip
        current_level = level

        counters[level - 1] += 1
        (level...3).each { |i| counters[i] = 0 }

        number_parts = []
        (0...level).each do |i|
          number_parts << (counters[i] > 0 ? counters[i].to_s : "1")
        end
        current_number = number_parts.join(".")

        current_text_lines = []
      else
        if !current_number.empty? && !para.text.strip.empty?
          current_text_lines << para.text.strip
        end
      end
    end

    if !current_number.empty?
      sections << {
        number: current_number,
        title: current_title,
        text: current_text_lines.join("\n").strip,
        level: current_level
      }
    end

    sections
  end

  def get_heading_level(paragraph)
    style_name = begin
      paragraph.style || ""
    rescue
      ""
    end
    
    if style_name == "Heading 1"
      1
    elsif style_name == "Heading 2"
      2
    elsif style_name == "Heading 3"
      3
    else
      0
    end
  end

  def filter_leaves(sections)
    parent_numbers = Set.new
    sections.each do |sec|
      parent = find_parent(sec[:number], sec[:level])
      parent_numbers << parent if parent
    end

    sections.reject { |sec| parent_numbers.include?(sec[:number]) }
  end

  def find_parent(number, level)
    return nil if level <= 1
    parts = number.split(".")
    parts[0..-2].join(".")
  end

  def generate_csv(sections)
    CSV.generate(col_sep: ";") do |csv|
      csv << ["Тема", "Описание", "Статус", "Трекер", "Приоритет"]

      sections.each do |sec|
        first_num = sec[:number][0].to_i
        if first_num >= 3
          csv << [
            "#{sec[:number]} #{sec[:title]}",
            sec[:text],
            "Бэклог",
            "Входящий поток",
            "Важная"
          ]
        end
      end
    end
  end
end