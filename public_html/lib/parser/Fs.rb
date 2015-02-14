# encoding: utf-8
require "base64"

class Fs < Parser

  attr_reader :search_a, :play, :sound, :pg, :test

  def initialize
    @search_a = []
    @test = []
    @pg = []
    @log = Log.new
  end

  def code_status(url)
    text = %x[curl --head "#{url}"]
    code = text.scan(/^HTTP\/1.1 (\w*)/)
    code = code[0].to_a
    code[0].to_s
  end

  def page(url)
    begin
      uri = URI(url)
      Net::HTTP.get_response(uri)
    rescue
    end
  end

  def nokogiri(url)
    page = self.page(url)
    unless page.nil?
      Nokogiri::HTML(page.body)
    end
  end

  def redirected_link(url)
    text = %x[curl -I -L "#{url}"]
    u = text.scan(/Location: ([^\n]+)/).flatten.last.to_s.chomp
    @test << u
    #URI.escape(u.chomp)
    @log.logs "#{url}"" ----- #{u}"
    u
  end

  def redirected_link_file(url)
    u =''
    text = %x[curl -I -L "#{url}"]
    l = text.scan(/Location: ([^\n]+)/).flatten
    l.each{|redir|
      u = redir.chomp if redir.include?('file')
    }
    @test = u
    @log.logs "#{url}"" ----- #{u}"
    u
  end

  def fs_page_video(url)
    p = url.split('/')
    hash = p[5].split('-')
    return  "http://fs.to/view/#{hash[0]}"
  end

  def fs_url_video(html)
    h = html.at('body').inner_text
    uri = h.scan(/'\/(get)\/(dl)\/(\w*)\/(.*)/).join("/").delete("',").chomp
    "http://fs.to/" + uri
  end

  def fs_url_sound(html)
    h = {}
    html.css("div.m-sound li a").each{|link|
      l = "http://fs.to" + redirected_link("http://fs.to" + link['href'])
      res = fs_url_resolution(l)
      audio = link['href'].scan(/audio_language=([а-яА-я]*)&translate=([а-яА-я]*)&translation=([а-яА-я]*)/)
      h[audio[0]] = res
    }
    return h
  end

  def fs_url_resolution(html)
    h = {}
    d = nokogiri html
    d.css("div.m-quality li a").each{|link|
      a = []
      u = "http://fs.to" +redirected_link( "http://fs.to" + link['href'])
      d = nokogiri u
      http = fs_url_video d
      play = redirected_link(http)
      a << u
      a << play
      h[link.text] = a
    }
    return h
  end

  def parser_video(link, date=nil)
    video = {}
    prev = "http://fs.to" + link['href']
    page_video = fs_page_video(prev)
    href = "http://fs.to" + redirected_link(page_video)
    video['date'] = date
    video['prev'] = prev
    video['page_video'] = page_video
    video['url'] = href
    doc = nokogiri href
    video['audio'] = fs_url_sound(doc)
    d = nokogiri prev
    d.search("div.b-tab-item").each{|div|
      div.search("div.head__title h1").each{|h1|
        video['name']  = h1.text.delete("\n").delete("\t")}

      div.search("div.poster-main a img").each{|img|
        video['image'] = img["src"]}

      genre = div.search("div.item-info tr")[0]
      video["genre"] = genre.css("td")[1].text.delete("\n")

      year = div.search("div.item-info tr")[1]
      video["year"] = year.css("td")[1].text.delete("\n")

      country = div.search("div.item-info tr")[2]
      video["country"] = country.css("td")[1].text.delete("\n")

      producer = div.search("div.item-info tr")[3]
      video["producer"] = producer.css("td")[1].text.delete("\n")

      cast = div.search("div.item-info tr")[4]
      video["cast"] = cast.css("td")[1].text.delete("\n")

      notice = div.search("div.item-info p")
      video["notice"] = notice.text.delete("\n")

    }
    return video

  end

  def parser_page_films(start_p,  end_p)
      if start_p == 0
        url = 'http://fs.to/video/films/?sort=new'
      else
        url = 'http://fs.to/video/films/?sort=new&page='"#{start_p}"''
      end
      doc = nokogiri url
      section = doc.css("div.b-poster-section a")
      unless section == ''
        section.each{|link|
          date = link.css("b.date").text.delete("\n")
          @pg << parser_video(link, date)
        }
        unless start_p == end_p
          start_p +=1
          parser_page_films(start_p, end_p)
        end
      else
        section = "END"
      end
      @test = ''
  end

  def film_error_name(prev)
    d = nokogiri prev
    video = {}
    d.search("div.b-tab-item").each{|div|
      div.search("div.head__title h1").each{|h1|
      video['name']  = h1.text.delete("\n").delete("\t")}

      div.search("div.poster-main a img").each{|img|
      video['image'] = img["src"]}

      genre = div.search("div.item-info tr")[0]
      video["genre"] = genre.css("td")[1].text.delete("\n")

      year = div.search("div.item-info tr")[1]
      video["year"] = year.css("td")[1].text.delete("\n")

      country = div.search("div.item-info tr")[2]
      video["country"] = country.css("td")[1].text.delete("\n")

      producer = div.search("div.item-info tr")[3]
      video["producer"] = producer.css("td")[1].text.delete("\n")

      cast = div.search("div.item-info tr")[4]
      video["cast"] = cast.css("td")[1].text.delete("\n")

      notice = div.search("div.item-info p")
      video["notice"] = notice.text.delete("\n")
    }
    video
  end

  def film_error_video(page_video)
     href = "http://fs.to" + redirected_link_file(page_video)
     doc = nokogiri href
     fs_url_sound(doc)
   end


end

