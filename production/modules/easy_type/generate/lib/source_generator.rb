require 'erb'

class SourceGenerator

  def self.generate(module_name, toc, type)
    @module_name = module_name
    @template_dir = File.expand_path(File.dirname(__FILE__)) + "/../templates/#{type}"
    toc.parse.each {|e| SourceGenerator.new(e).generate }
  end

  def self.template_dir
    @template_dir
  end

  def self.module_name
    @module_name
  end

  def initialize(entry)
    @entry = entry
  end

  def template_dir
    self.class.template_dir
  end

  def module_name
    self.class.module_name
  end

  def generate
    if @entry.automated
      generate_rspec_unit_test
      generate_rspec_acceptance_test
      generate_control
      generate_docs
    end
  end

  def generate_rspec_acceptance_test
    rspec_name = "./spec/acceptance/#{@entry.control_name}_spec.rb"
    return if File.exists?(rspec_name)
    puts "Generating spec file for #{@entry.control_name}..."
    renderer = ERB.new(File.read("#{template_dir}/acceptance_test.rb.erb"))
    File.write(rspec_name, renderer.result(binding))
  end

  def generate_rspec_unit_test
    rspec_name = "./spec/defines/controls/#{@entry.control_name}_spec.rb"
    return if File.exists?(rspec_name)
    puts "Generating spec file for #{@entry.control_name}..."
    renderer = ERB.new(File.read("#{template_dir}/unit_test.rb.erb"))
    File.write(rspec_name, renderer.result(binding))
  end

  def generate_control
    control_file = "./manifests/controls/#{@entry.control_name}.pp"
    return if File.exists?(control_file)
    puts "Generating control class file for #{@entry.control_name}..."
    renderer = ERB.new(File.read("#{template_dir}/control.rb.erb"))
    File.write(control_file, renderer.result(binding))
  end


  def generate_docs
    docs_file = "./documentation/source/controls/#{@entry.control_name}.md"
    return if File.exists?(docs_file)
    puts "Generating documentation for #{@entry.control_name}..."
    renderer = ERB.new(File.read("#{template_dir}/doc.md.erb"))
    File.write(docs_file, renderer.result(binding))
  end

end