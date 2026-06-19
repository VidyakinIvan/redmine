require 'docx'
require 'csv'

class DocxParser
  def initialize(file_path)
    @doc = Docx::Document.open(file_path)
  end

def parse(mode = 'cards')
  sections = extract_sections
  if mode == 'checklist'
    filtered = sections.select { |sec| sec[:level] == 2 || sec[:level] == 3 }
  else
    filtered = filter_leaves(sections)
  end
  generate_csv(filtered)
end

  private

def extract_sections
  sections = []
  current = nil
  counters = [0, 0, 0]

  @doc.paragraphs.each do |para|
    style = begin
      para.style
    rescue
      ''
    end
    
    if style && style.match?(/Heading|heading|Заголовок|heading\s*\d|заголовок\s*\d/i)
      level = style.match(/Heading\s*(\d)/i) || style.match(/[Зз]аголовок\s*(\d)/)
      level = level ? level[1].to_i : 1
	  
	  next if level > 3
	  
	  if current
        sections << current
      end

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
	  CSV.generate(col_sep: ';') do |csv|
		csv << ['Тема', 'Описание', 'Статус', 'Трекер', 'Приоритет', 'Уровень']

		sections.each do |sec|
		  first_num = sec[:number].split('.').first.to_i
		  next unless first_num >= 3

		  csv << [
			"#{sec[:number]} #{sec[:title]}",
			sec[:text].strip,
			"Бэклог",
			"Входящий поток",
			"Важная",
			sec[:level]
		  ]
		end
	  end
	end
end