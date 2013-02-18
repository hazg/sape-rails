require 'net/http'

# Originally by: Dmitry Root (droot@deeptown.org)
# http://forum.searchengines.ru/showthread.php?t=237277


module Sape
  class Processor

    @@default_options = {
      :force_show_code => true,
      :charset => 'utf-8',
      :server => 'dispencer-01.sape.ru',
      :timeout => 60 * 60 * 1             # use nil if you don't want to get updates
                                          # In this case, you have to call update()
                                          # manually in the cron job, for ex.
    }

    attr_reader :options

    class InvalidArguments < Exception
    end

    class RequestError < Exception
    end

    class ContentError < Exception
    end

    # don't call new() directly!
    def initialize(opts)
      @options = @@default_options.merge(opts)
      [ :user, :host, :uri, :remote_ip, :filename, :charset, :server ].each do |i|
        raise InvalidArguments.new("missing argument #{i}") unless @options[i]
      end
      @options[:uri_alt] = @options[:uri][-1, 1] == '/' ? @options[:uri][0..-2] : (@options[:uri] + '/')
    end

    # construct Sape object from environment variables
=begin
    def self.from_env(user, extra_opts = {})
      Sape::Processor.new( {
        :user => user,
        :host => ENV['HOSTNAME'] || ENV['HTTP_HOST'],
        :uri => ENV['ORIGINAL_FULLPATH'],
        :remote_ip => ENV['REMOTE_ADDR'],
        :filename => ENV['DOCUMENT_ROOT'] + '/links.db'
      }.merge(extra_opts) )
    end
=end
    # construct Sape object from ActionController::AbstractRequest
    def self.from_request(user, request, extra_opts = {})
      Sape::Processor.new( {
        :user => user,
        :host => request.host,
        :uri => request.fullpath,
        :remote_ip => request.remote_ip,
        :filename => Rails.root.join('tmp/links.db').to_s
      }.merge(extra_opts) )
    end

    # get fist N links from queue (use nil to get full queue)
    # automatically fetches the links if still not fetched
    def get_links(count = nil)
      fetch_links unless @links
      need_count = count || @links.size
      rc = @links[0..need_count-1].join(@delimiter)
      @links = @links[need_count..-1]
      rc
    end
    
    # as prev. method, but return a error code if an exception
    # raises
    def links(count = nil)
      return @sape_error if @sape_error
      unless @links
        begin
          fetch_links
        rescue Exception => e
          @sape_error = "<!-- SAPE.ru error: #{e.message} -->"
          return @sape_error
        end
      end
      get_links(count)
    end

    # update the links database
    def update
      file = File.new(@options[:filename], 'a+')
      if file.flock(File::LOCK_EX | File::LOCK_NB)
        resp = fetch("http://#{@options[:server]}" +
                     "/code.php?user=#{@options[:user]}&" +
                     "host=#{@options[:host]}&" +
                     "as_txt=true&" +
                     "charset=#{@options[:charset]}&" +
                     "no_slash_fix=true")
        raise RequestError.new("request error '#{resp.message}'") unless resp.is_a? Net::HTTPSuccess
        content = resp.body
        all_links = parse_links(content)
        raise ContentError.new("no '__sape_new_url__' in links text") unless all_links['__sape_new_url__']
        file.seek(0)
        file.truncate(0)
        file.write(content)
        file.close
        return all_links
      end
      nil
    end

  private

    def fetch(url, limit = 10)
      raise RequestError.new('HTTP redirect too deep') if limit == 0

      resp = Net::HTTP.get_response(URI.parse(url))
      return fetch(resp['location'], limit-1) if resp.is_a? Net::HTTPRedirection

      resp
    end

    # load links from cache and update them if needed
    def fetch_links
      
      all_links = fetch_all_links
      @links = all_links[@options[:uri]] || all_links[@options[:uri_alt]]
      @ips = all_links['__sape_ips__'] || []
      @links = all_links['__sape_new_url__'] if !@links && (@options[:force_show_code] || !(@ips & [ @options[:remote_ip] ]).empty?)
      @links = [] unless @links
    end

    def fetch_all_links
      if @options[:timeout]
        begin
          stat = File.stat(@options[:filename])
        rescue
          stat = nil
        end
        return update if !stat || stat.mtime < Time.now - @options[:timeout] || stat.size == 0
      end
      file = File.new(@options[:filename], 'r')
      parse_links(file.read)
    end

    def parse_links(data)
      lines = data.split("\n")
      @delimiter = lines[1]
      rc = Hash.new
      lines[2..-1].each do |line|
        items = line.split('||SAPE||')
        rc[ items[0] ] = items[1..-1]
      end
      rc
    end

  end
end
