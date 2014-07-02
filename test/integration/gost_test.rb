require 'test_helper'
require 'openssl'
require 'socket'

class GostTest < ActionDispatch::IntegrationTest

  setup :initialize_gost
  setup do
    ruby_executable_path = File.join( RbConfig::CONFIG['bindir'], RbConfig::CONFIG['RUBY_INSTALL_NAME'] + RbConfig::CONFIG['EXEEXT'])
    puts "This test is run under Ruby which located at #{ruby_executable_path}"
  end

  test 'connection to the HTTPS server with GOST algorithm' do
    socket = TCPSocket.open('ssl-gost.envek.name', 443)
    ssl_context = OpenSSL::SSL::SSLContext.new()
    ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ssl_context)
    ssl_socket.sync_close = true
    ssl_socket.connect

    request = <<-EOR.gsub(/^\s{6}/, '')
      GET / HTTP/1.1
      Host: ssl-gost.envek.name
      Connection: close

    EOR
    # Don't remove blank line above!

    ssl_socket.puts(request)
    reply = ssl_socket.read
    ssl_socket.close

    assert reply =~ /GOST2001/
  end

  test 'Able to read GOST private key and do signing' do
    crt = OpenSSL::X509::Certificate.new(File.read('test/fixtures/gost_r_34_10_2001_certificate.pem'))
    privkey = OpenSSL::PKey.read(File.read('test/fixtures/gost_r_34_10_2001_private_key.pem'))

    data = 'Some message'
    dgst94  = @gost_engine.digest('md_gost94')
    signature = privkey.sign(dgst94, data)

    assert crt.public_key.verify(dgst94, signature, data) # Should be true
    refute crt.public_key.verify(dgst94, signature, data.sub('S', 'Not s')) # Should be false
  end

  protected

  def initialize_gost
    OpenSSL::Engine.load
    @gost_engine = OpenSSL::Engine.by_id('gost')
    @gost_engine.set_default(0xFFFF) # It's required, but I don't know why
  end
end
