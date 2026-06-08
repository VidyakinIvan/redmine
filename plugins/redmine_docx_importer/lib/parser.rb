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
      style = para.paragraph_style || ''
      
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
      parts = sec[:number].split('.')
      if parts.length > 1
        parent_numbers << parts[0..-2].join('.')
      end
    end

    sections.reject { |sec| parent_numbers.include?(sec[:number]) }
  end

  def generate_csv(sections)
    number_to_title = sections.each_with_object({}) { |s, h| h[s[:number]] = s[:title] }

    CSV.generate(col_sep: ';') do |csv|
      csv << ['Номер раздела', 'Тема задачи', 'Описание', 'Уровень', 'Родительский раздел', 'Тема родителя']

      sections.each do |sec|
        parts = sec[:number].split('.')
        parent_number = parts.length > 1 ? parts[0..-2].join('.') : ''
        parent_title = number_to_title[parent_number] || ''

        csv << [
          sec[:number],
          sec[:title],
          sec[:text].strip,
          sec[:level],
          parent_number,
          parent_title
        ]
      end
    end
  end
end