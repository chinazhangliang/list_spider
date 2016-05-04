require 'rchardet'
require 'net/http'

module SpiderHelper

  class << self

    def direct_http_get(href, local_path, params: nil, header: nil)
      if href.class == "".class
        href = string_to_uri(href)
      end

      begin
        href.query = URI.encode_www_form(params) if params
        req = Net::HTTP::Get.new(href)
        header.each{|k,v| req[k] = v} if header

        res = Net::HTTP.start(href.hostname, href.port) do |http|
          http.request(req)
        end

        if res.is_a?(Net::HTTPSuccess)
          local_dir = File.dirname(local_path)
          FileUtils.mkdir_p(local_dir) unless Dir.exist?(local_dir)
          File.write(local_path, res.body)
          puts "succeed"
        else
          puts res
        end
      rescue Exception => e
        puts e.backtrace
        puts e
      end
    end

    def direct_http_post(href, local_path, params, header: nil)
      if href.class == "".class
        href = string_to_uri(href)
      end

      begin
        req = Net::HTTP::Post.new(href)
        req.set_form_data(params)
        header.each{|k,v| req[k] = v} if header

        res = Net::HTTP.start(href.hostname, href.port) do |http|
          http.request(req)
        end

        if res.is_a?(Net::HTTPSuccess)
          local_dir = File.dirname(local_path)
          FileUtils.mkdir_p(local_dir) unless Dir.exist?(local_dir)
          File.write(local_path, res.body)
        else
          puts res
        end
      rescue Exception => e
        puts e
      end
    end

    def extract_href_last(origin_href)
      origin_href.split('/')[-1]
    end

    def string_to_uri(href)
      l = href
      l.sub!('http:///', 'http://') if l.start_with?('http:///')
      l = Addressable::URI.parse(l)
      l.normalize!
    end

    BomHeaderMap = {"UTF-8" => "\xEF\xBB\xBF".force_encoding("UTF-8"),
      "UTF-16BE"=>"\xFE\xFF".force_encoding("UTF-16BE"),
      "UTF-16LE"=>"\xFF\xFE".force_encoding("UTF-16LE"),
      "UTF-32BE"=>"\x00\x00\xFE\xFF".force_encoding("UTF-32BE"),
      "UTF-32LE"=>"\xFF\xFE\x00\x00".force_encoding("UTF-32LE")}

    #此函数有时此判断有误，使用to_utf8函数直接转换
    def smart_to_utf8(str)
      return str if str.encoding == Encoding::UTF_8
      to_utf8(str)
    end

    def to_utf8(str)
      #解决windows下CharDet库编译为ASCII_8BIT，无法与UTF-8兼容问题
      str.force_encoding(Encoding::ASCII_8BIT)
      cd = CharDet.detect(str)
      if cd["confidence"] > 0.6
        puts cd["encoding"]
        str.force_encoding(cd["encoding"])
        #移除BOM头
        bomHeader = BomHeaderMap[cd["encoding"]]
        str.sub!(bomHeader, "") if bomHeader
      end
      str.encode!(Encoding::UTF_8, :undef => :replace, :replace => "?", :invalid => :replace)
      
      return str
    end

  end

end