#
# This class is a super class to access all Puppet related services 
# in a conveniant way.
#
module EasyType
class PuppetService
  def initialize
    if Puppet[:tasks]
      hostname   = Facter.value('fqdn')
      @server    = hostname
      @host_cert = "/etc/puppetlabs/puppet/ssl/certs/#{hostname}.pem"
      @ca_cert   = "/etc/puppetlabs/puppet/ssl/certs/ca.pem"
      @key       = "/etc/puppetlabs/puppet/ssl/private_keys/#{hostname}.pem"
    else
      @server    = Puppet.settings['server']
      @host_cert = Puppet.settings['hostcert']
      @ca_cert   = Puppet.settings['localcacert']
      @key       = Puppet.settings['hostprivkey']
    end
  end

  def get(endpoint, query = nil)
    JSON.parse(https_call('get', endpoint, query).body)
  end

  def post(endpoint, data)
    JSON.parse(https_call('post', endpoint, nil, data).body)
  end

  private
  def https_call(operation, endpoint, query = nil, data = nil)
    Puppet.debug "Connecting to #{@base_url}#{endpoint}, using cert file #{@host_cert} and keyfile #{@key} with cacert #{@ca_cert}"
    uri              = URI("#{@base_url}#{endpoint}")
    uri             += "?query=#{query.to_s}" unless query.nil? || query.empty?
    http             = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl     = true
    http.cert        = OpenSSL::X509::Certificate.new(File.read @host_cert)
    http.key         = OpenSSL::PKey::RSA.new(File.read @key)
    http.ca_file     = @ca_cert
    http.verify_mode = OpenSSL::SSL::VERIFY_CLIENT_ONCE
    req              = Net::HTTP.const_get(operation.capitalize).new(uri.request_uri)
    req.body         = data.to_json if data
    req.content_type = 'application/json'
    http.request(req)
  end

end
end