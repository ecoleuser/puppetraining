class TocParser

  attr_reader :product, :version, :levels, :variants

  Entry = Struct.new(:title, :chapter, :control_name, :level, :variant, :automated )

  def initialize(product, version, levels, variants, post_processor)
    @product = product
    @version = version
    @levels = levels
    @variants = variants
    @toc_file = "generate/definitions/cis/#{@product}/#{@version}/TOC.txt"
    @post_processor = post_processor
  end

  def parse()
    entries = []
    levels_regexp   = @levels.collect {|l| "\\(\\s?#{l}\\s?\\)"}.join('|')
    variants_regexp = @variants.collect {|v| "\\(\\s?#{v}\\s?\\)"}.join('|')
    File.foreach(@toc_file) do |line|
      line_without_page = line.split('..')[0]
      level      = line_without_page.scan(/#{levels_regexp}/i)&.first&.gsub(/\(|\)/,'')
      variant    = line_without_page.scan(/#{variants_regexp}/i)&.first&.gsub(/\(|\)/,'')
      automated  = line_without_page.scan(/\(Automated\)/i)&.first&.gsub(/\(|\)/,'')
      scored     = line_without_page.scan(/\(Scored\)/i)&.first&.gsub(/\(|\)/,'')
      cleaned_up = line_without_page
        .gsub(/\(\s?Automated\s?\)/i,'')
        .gsub(/\(\s?Scored\s?\)/i,'')
        .gsub(/\(\s?Not Scored\s?\)/i,'')
        .gsub(/\(\s?Unscored\s?\)/i,'')
        .gsub(/#{levels_regexp}/i,'')
        .gsub(/#{variants_regexp}/i,'')
      parts = cleaned_up.split(' ')
      chapter = "p#{parts[0]}"
      control_name = parts[1..-1].join(' ')
        .gsub(/\"|\'|\(|\)|\:|\,|=|\[|\]/,'')
        .gsub(/\s|\.|\-|\%|\$|\\|\//,'_')
        .gsub('+','_plus_')
        .gsub('&','_and_')
        .gsub(/_+/,'_')
        .gsub(/^ensure_/,'')
        .gsub(/^configure_/,'')
        .gsub(/_automated$/,'')
        .gsub(/_manual$/,'')
        .gsub(/__/,'_')
        .gsub(/^_/,'')
        .gsub(/_$/,'')
        .downcase
        .gsub(/^ensure_/,'')
        .gsub(/^ensure_the_/,'')
        .gsub(/^configure_/,'')
        .gsub(/^the_/,'')
        .gsub(/__/,'_')

      entry = Entry.new(line_without_page, chapter, control_name, level, variant, automated || scored )
      entries << @post_processor.call(entry)
    end
    entries
  end
end