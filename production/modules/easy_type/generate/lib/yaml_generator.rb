class YamlGenerator

  def self.generate(module_name, toc, type)
    @module_name = module_name
    entry = new(toc, type)
    entry.create_dirs
    entry.create_yamls
  end

  def self.module_name
    @module_name
  end

  def module_name
    self.class.module_name
  end

  def initialize(toc, type)
    @base_dir = "./data/benchmarks/#{type}"
    @parsed_data = toc.parse
    @entries = toc.parse
    @product = toc.product
    @levels = toc.levels
    @variants = toc.variants
    @version = toc.version
  end

  def create_dirs
    create_dir("#{@base_dir}/#{@product}")
    create_dir("#{@base_dir}/#{@product}/#{@version}")
  end

  def create_yamls
    puts "Generating yaml data for #{@product} #{@version}..."
    defaults_file = yaml_file("#{@base_dir}/#{@product}/#{@version}/defaults.yaml")
    @parsed_data.each do | entry|
      next unless entry.automated
      line = "  %-18s %s\n" % ["#{entry.chapter.gsub('.','_')}:", entry.control_name]
      defaults_file.write(line)
    end
    defaults_file.close()
  end

  def create_dir(dir_name)
    FileUtils.mkdir(dir_name) unless File.exists?(dir_name)
  end

  def yaml_file(file_name)
    file = File.open(file_name, "w")
    file.write("---\n")
    file.write("#{module_name}::control_map:\n")
    file
  end

end