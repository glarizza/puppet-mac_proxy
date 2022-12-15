require_relative '../mac_proxy'

Puppet::Type.type(:mac_socks_proxy).provide(:ruby, parent: Puppet::Provider::MacProxy) do
  commands networksetup: 'networksetup'

  # Automagically create getter/setter methods for prefetching/flushing
  mk_resource_methods

  def self.get_proxy_type
    :socks
  end

  def get_proxy_type
    self.class.get_proxy_type
  end
end
