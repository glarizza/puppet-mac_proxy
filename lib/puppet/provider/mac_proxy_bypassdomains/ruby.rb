require 'puppet/provider/mac_proxy'

Puppet::Type.type(:mac_proxy_bypassdomains).provide(:ruby, :parent => Puppet::Provider::MacProxy) do
  commands :networksetup => 'networksetup'

  def self.instances
    interfaces = get_list_of_interfaces
    array_of_interfaces = interfaces.collect do |int|
      new({
        :name    => int,
        :domains => get_proxy_bypass_domains(int),
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
    return nil if domains.first =~ /There aren\'t any bypass domains set/
    domains
  end

  def exists?
    self.class.get_proxy_bypass_domains(resource[:name]) != nil
  end

  def destroy
    networksetup(['setproxybypassdomains', nil])
  end

  def create
    Puppet.debug "YOU ARE IN CREATE!"
    networksetup(['-setproxybypassdomains', resource[:name], resource[:domains]])
  end

  def domains
    self.class.get_proxy_bypass_domains(resource[:name])
  end

  def domains=(value)
    networksetup(['-setproxybypassdomains', resource[:name], value])
  end
end

