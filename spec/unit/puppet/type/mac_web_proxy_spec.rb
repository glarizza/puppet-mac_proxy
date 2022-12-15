require 'puppet'
require 'puppet/type/mac_web_proxy'

describe Puppet::Type.type(:mac_web_proxy) do
  let(:resource) do
    Puppet::Type.type(:mac_web_proxy).new(
      name: 'wi-fi',
      proxy_server: 'http://proxy.myorg.com',
      proxy_port: '8088',
    )
  end

  it 'is ensurable' do
    resource[:ensure] = :present
    expect(resource[:ensure]).to eq(:present)
    resource[:ensure] = :absent
    expect(resource[:ensure]).to eq(:absent)
  end

  it 'munges the namevar' do
    resource[:name] = 'WI-FI'
    expect(resource[:name]).to eq('wi-fi')
  end

  it 'raises an error if an invalid ensure value is passed' do
    expect { resource[:ensure] = 'file' }.to raise_error \
      Puppet::Error, %r{Invalid value "file"}
  end

  it 'accepts a valid proxy_port value' do
    resource[:proxy_port] = '8080'
    expect(resource[:proxy_port]).to eq('8080')
  end

  it 'raises an error if a valid proxy_port is not provided' do
    expect { resource[:proxy_port] = 'foo' }.to raise_error Puppet::Error
  end

  it 'accepts a valid proxy_authenticated value' do
    resource[:proxy_authenticated] = true
    expect(resource[:proxy_authenticated]).to eq(:true)
    resource[:proxy_authenticated] = false
    expect(resource[:proxy_authenticated]).to eq(:false)
  end

  it 'raises an error if a valid proxy_authenticated value is not provided' do
    expect { resource[:proxy_authenticated] = 'foo' }.to raise_error Puppet::Error
  end
end
