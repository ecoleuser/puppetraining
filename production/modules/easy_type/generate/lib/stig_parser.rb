require 'json'

class StigParser

  MAX_CONTROL_NAME_LENGTH = 97

  attr_reader :product, :version, :levels, :variants

  Entry = Struct.new(:title, :control_name , :description, :chapter, :automated)

  def initialize(product, version, levels, variants, post_processor)
    @product = product
    @version = version
    @levels = levels
    @variants = variants
    @stig_file = "generate/definitions/stig/#{@product}/#{@version}/TOC.json"
    @content = JSON.parse(File.read(@stig_file))
    @post_processor = post_processor
  end

  def handle_to_long_control_names(control_name)
    return control_name if control_name.length < MAX_CONTROL_NAME_LENGTH
    control_name = control_name
      .gsub('_the_','_')
      .gsub('oracle','orcl')
      .gsub('database','db')
      .gsub('authorized', 'auth')
      .gsub('privilege', 'priv')
      .gsub('grant','grnt')
      .gsub('administrator', 'admin')
      .gsub('account', 'accnt')
      .gsub('system', 'sys')
      .gsub('password', 'pwd')
      .gsub('application', 'app')
      .gsub('platform', 'plfrm')
      .gsub('production', 'prod')
      .gsub('protected', 'prot')
      .gsub('remote','rmt')
      .gsub('organizational','org')
      .gsub('organization', 'org')
      .gsub('authentication', 'auth')
      .gsub('connection', 'conns')
      .gsub('tier', 'tr')
      .gsub('configuration','config')
      .gsub('information', 'info')
      .gsub('developer','dev')
      .gsub('external','ext')
      .gsub('network','netw')
      .gsub('directories','dirs')
      .gsub('administration', 'admin')
      .gsub('sufficient', 'suff')
      .gsub('authorizations','auths')
      .gsub('generated', 'gen')
      .gsub('generate', 'gen')
      .gsub('available', 'avail')
      .gsub('requirement', 'req')
      .gsub('authenticated','auth')
      .gsub('configured', 'configed')
      .gsub('containing', 'cont')
      .gsub('protect', 'prot')
      .gsub('records', 'recs')
      .gsub('credential','cred')
      .gsub('directory','dir')
      .gsub('logical','log')
      .gsub('restrictions','rstctns')
      .gsub('software','sw')
      .gsub('libraries','libs')
      .gsub('restrict','rstrct')
      .gsub('individual','indiv')
      .gsub('performed','perfd')
      .gsub('support','supp')
      .gsub('prohibit','prhbt')
      .gsub('discretionary_access_control_dac','dac')
      .gsub('procedures','procs')
      .gsub('accordance','acc')
      .gsub('priority','prio')
      .gsub('development','dev')
      .gsub('specifically','spec')
      .gsub('processes','procs')
      .gsub('approved','apprvd')
      .gsub('management','mgmt')
      .gsub('terminate', 'term')
      .gsub('utilizing','utlzng')
      .gsub('includes','incl')
      .gsub('include','incl')
      .gsub('excludes','excl')
      .gsub('techniques','techs')
      .gsub('maintenance','maint')
      .gsub('diagnostic','diag')
      .gsub('identification','ident')
      .gsub('associated','ass')
      .gsub('communications','comms')
      .gsub('establish','est')
      .gsub('identity', 'id')
      .gsub('integrity','int')
      .gsub('confidentiality', 'conf')
      .gsub('extracted','extr')
      .gsub('derived', 'dervd')
      .gsub('from', 'frm')
      .gsub('limit','lmt')
      .gsub('encrypt','encrpt')
      .gsub('stored','strd')
      .gsub('digital','dig')
      .gsub('identified', 'idntfd')
      .gsub('security', 'sec')
      .gsub('architecture', 'arch')
      .gsub('documentation', 'doc')
      .gsub('sessions','sess')
      .gsub('access', 'acc')
      .gsub('defined', 'def')
      .gsub('list', 'lst')
      .gsub('inappropriate','inappr')
      .gsub('functions','funcs')
      .gsub('relevant', 'rel')
      .gsub('additional','add')
      .gsub('detailed', 'det')
      .gsub('temporary', 'tmp')
      .gsub('documented', 'doc')
      .gsub('implemented', 'impl')
      .gsub('activities','act')
      .gsub('automated', 'autom')
      .gsub('mechanisms', 'mechs')
      .gsub('monitored', 'mon')
      .gsub('discover', 'disc')
      .gsub('packages','pkgs')
      .gsub('triggers','trggrs')
      .gsub('must','must')
      .gsub('provide', 'prov')
      .gsub('capability', 'cap')
      .gsub('automatically', 'autom')
      .gsub('process', 'proc')
      .gsub('different', 'diff')
      .gsub('media', 'med')
    control_name[0..MAX_CONTROL_NAME_LENGTH-1].gsub(/_$/,'')
  end

  def parse()
    entries = []
    @content['stig']['findings'].each do | finding|
      title = finding[1]['title']
      control_name = title
        .gsub(/\"|\'|\(|\)|\;|\:|\,|=|\[|\]/,'')
        .gsub(/\s|\.|\-|\%|\$|\\|\//,'_')
        .gsub('*','')
        .gsub('+','_plus_')
        .gsub('&','_and_')
        .gsub(/_+/,'_')
        .gsub(/__/,'_')
        .gsub(/^_/,'')
        .gsub(/_$/,'')
        .downcase
        .gsub(/__/,'_')
        .gsub(/^the_dbms_must_/,'')
        .gsub(/^dbms_must_/,'')
        .gsub(/^the_/,'')
        .gsub(/^system_must_/,'')
        .gsub(/^a_/,'')
      control_name = handle_to_long_control_names(control_name)
      automated = true
      description = finding[1]['checktext'] + "\n\n" + finding[1]['fixtext']
      chapter = finding[1]['id']
      entry = Entry.new(title, control_name, description, chapter, automated )
      entries << entry
    end
    entries
  end
end