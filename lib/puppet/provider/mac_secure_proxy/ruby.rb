require 'puppet/provider/mac_proxy'

Puppet::Type.type(:mac_secure_proxy).provide(:ruby, :parent => Puppet::Provider::MacProxy) do
  commands :networksetup => 'networksetup'

  # Automagically create getter/setter methods for prefetching/flushing
  mk_resource_methods

  def self.get_proxy_type
    :web
  end

  def get_proxy_type
    self.class.get_proxy_type
  end
end
