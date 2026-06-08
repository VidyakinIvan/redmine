require 'docx'
require 'csv'

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
    current = nil
    counters = Hash.new(0)

    @doc.paragraphs.each do |para|
      style = begin
        para.style || ''
      rescue
        ''
      end
      
      if style.match?(/Heading|heading|Заголовок|heading\s*\d|заголовок\s*\d/i)
        if current
          sections << current
        end

        level = style.match(/Heading\s*(\d)/i) || style.match(/[Зз]аголовок\s*(\d)/)
        level = level ? level[1].to_i : 1

        counters[level] += 1
        (level + 1..10).each { |i| counters[i] = 0 }

        parts = (1..level).map { |i| counters[i] }
        number = parts.join('.')

        current = {
          number: number,
          title: para.text.strip,
          text: '',
          level: level
        }
      elsif current
        text = para.text.strip
        current[:text] += "#{text}\n" unless text.empty?
      end
    end

    sections << current if current
    sections
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
            sec[:text].strip,
            "Бэклог",
            "Входящий поток",
            "Важная"
          ]
        end
      end
    end
  end
end