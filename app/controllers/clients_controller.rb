class ClientsController < ApplicationController
  def install
    @server_url = "#{request.protocol}#{request.host_with_port}"
    render layout: false, content_type: 'text/plain'
  end

  def tarball
    content = `tar c -C #{Shellwords.shellescape Rails.root} --transform='s,^client,game-changer,' client/`
    raise "Problem with tar" unless $? == 0
    send_data content, filename: 'client.tar'
  end
end
