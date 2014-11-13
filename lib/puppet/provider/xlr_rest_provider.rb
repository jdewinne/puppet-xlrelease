require 'puppet'
require 'open-uri'
require 'net/http'
require 'json'

class Puppet::Provider::XLReleaseRestProvider < Puppet::Provider

  # def rest_get(service)
  #   begin
  #     response = RestClient.get "#{resource[:rest_url]}/#{service}", {:accept => :xml, :content_type => :xml }
  #   rescue Exception => e
  #     return e.message
  #   end
  # end
  #
  # def rest_post(service, body='')
  #   RestClient.post "#{resource[:rest_url]}/#{service}", body, {:content_type => :xml }
  # end
  #
  # def rest_put(service, body='')
  #   RestClient.put "#{resource[:rest_url]}/#{service}", body, {:content_type => :xml }
  # end
  #
  # def rest_delete(service)
  #   RestClient.delete "#{resource[:rest_url]}/#{service}", {:accept => :xml, :content_type => :xml }
  # end

  def rest_get(service)
    execute_rest(service, 'get')
  end

  def rest_post(service, body='')
    execute_rest(service, 'post', body)
  end

  def rest_put(service, body='')
    execute_rest(service, 'put', body)
  end

  def rest_delete(service)
    execute_rest(service, 'delete')
  end

  def ci_exists?(id)
    begin
      rest_get("repository/export/#{id}")
      return true
    rescue Exception => e
      p e.message
      return false
    end
  end

  def execute_rest(service, method, body='')

    uri = URI.parse("#{resource[:rest_url]}/#{service}")

    http = Net::HTTP.new(uri.host, uri.port)
    request = case method
                when 'get'    then Net::HTTP::Get.new(uri.request_uri)
                when 'post'   then Net::HTTP::Post.new(uri.request_uri)
                when 'put'    then Net::HTTP::Put.new(uri.request_uri)
                when 'delete' then Net::HTTP::Delete.new(uri.request_uri)
              end
    #p request.pretty_print_inspect

    request.basic_auth(uri.user, uri.password) if uri.user and uri.password
    request.body = body unless body == ''
    request.content_type = 'application/json'

    begin
      p request
      res = http.request(request)
      raise Puppet::Error, "cannot send request to deployit server #{res.code}/#{res.message}:#{res.body}" unless res.is_a?(Net::HTTPSuccess)
      return res.body
    rescue Exception => e
      p e.message
      return e.message
    end

  end


  def to_json(id, type, properties)
    p "to_json"
    json_hash = {"id" => id, "type" => type}.merge(properties)
    p json_hash
    return json_hash
  end

  def to_hash(json)
    p "to hash"
    p JSON.parse(json)
    JSON.parse(json)
  end


end


