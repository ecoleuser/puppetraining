class DocGenerator

    def self.generate(module_nane, toc, type)
      entry = new(toc, type, module_name)
      entry.create_doc
    end
  
    def initialize(toc, type, module_name)
      @type = type
      @module_name = module_name
      @base_dir = './documentation'
      @parsed_data = toc.parse
      @entries = toc.parse
      @product = toc.product
      @levels = toc.levels
      @variants = toc.variants
      @version = toc.version
    end
  
  
  def create_doc
    puts "Generating top level documentation for #{@type} #{@product} #{@version}..."
    doc_file = doc_file("#{@base_dir}/#{@type}/#{@product}_#{@version}.md")
    @parsed_data.each do | entry|
      if entry.chapter =~ /^p[0-9]+$/ # We are a top level chapter
        doc_file.write("\n")
        doc_file.write("## #{entry.title}\n")
        doc_file.write("\n")
      elsif entry.automated
        doc_file.write("[#{entry.title}](/docs/#{@module_name}/controls/#{entry.control_name}.html)  \n")
      else
        doc_file.write("#{entry.title}  \n")
      end
    end
    doc_file.close()
  end

  def doc_file(file_name)
    file = File.open(file_name, "w")
    name = "Oracle Database #{@product.tr('db','')}"
    file.write("---\n")
    file.write("title: #{name} CIS #{@version}\n")
    file.write("keywords: documentation\n")
    file.write("layout: documentation\n")
    file.write("sidebar: #{@module_name}_sidebar\n")
    file.write("toc: false\n")
    file.write("---\n")
    file.write("Here is a list of all controls implemented in this puppet module. The link takes you to the documentation of the implementation class.\n")
    file
  end


end