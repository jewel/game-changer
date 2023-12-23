# Handle communication with the server over HTTP.

class Server
  class << self
    def bucket_url hash
      "#{server_url}bucket/#{hash[0...2]}/#{hash[0...4]}/#{hash}"
    end

    def server_url
      "http://localhost:4004/"
    end

    def get uri
      res = HTTParty.get "#{server_url}#{uri}", format: :plain
      JSON.parse res.body, symbolize_names: true
    end

    def fetch_bucket hash
      res = HTTParty.get bucket_url hash
      raise "Can't fetch #{hash}" unless res.code == 200
      res.body
    end
  end
end
