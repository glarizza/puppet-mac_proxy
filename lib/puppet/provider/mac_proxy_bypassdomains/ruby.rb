require_relative '../mac_proxy'

Puppet::Type.type(:mac_proxy_bypassdomains).provide(:ruby) do
  commands networksetup: 'networksetup'

  def self.instances
    interfaces = Puppet::Provider::MacProxy.get_list_of_interfaces
    array_of_interfaces = interfaces.map do |int|
      new({
            name: int,
        domains: get_proxy_bypass_domains(int),
          })
    end
    array_of_interfaces
  end

  def self.get_proxy_bypass_domains(int)
    begin
      output = networksetup(['-getproxybypassdomains', int])
    rescue Puppet::ExecutionFailure => e
      Puppet.debug("#get_proxy_bypass_domains had an error -> #{e.inspect}")
      return nil
    end
    domains = output.split("\n").sort
    return nil if %r{There aren\'t any bypass domains set}.match?(domains.first)
    domains
  end

  def exists?
    self.class.get_proxy_bypass_domains(resource[:name]) != nil
  end

  def destroy
    networksetup(['setproxybypassdomains', nil])
  end

  def create
    networksetup(['-setproxybypassdomains', resource[:name], resource[:domains]])
  end

  def domains
    self.class.get_proxy_bypass_domains(resource[:name])
  end

  def domains=(value)
    networksetup(['-setproxybypassdomains', resource[:name], value])
  end
end
