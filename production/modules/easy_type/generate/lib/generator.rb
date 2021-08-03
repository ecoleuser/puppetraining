require_relative './toc_parser'
require_relative './stig_parser'
require_relative './source_generator'
require_relative './yaml_generator'
require_relative './doc_generator'

class Generator
  def self.generate(module_name, type, *args)
    case type
    when 'cis'
      benchmark = TocParser.new(*args)
    when 'stig'
      benchmark = StigParser.new(*args)
    else
      fail "'#{type}' not valid as a benchmark type"
    end
    SourceGenerator.generate(module_name, benchmark, type)
    YamlGenerator.generate(module_name, benchmark, type)
    DocGenerator.generate(module_name, benchmark, type)
  end
end