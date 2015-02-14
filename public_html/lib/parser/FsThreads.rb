# encoding: utf-8

class FsThreads < Parser

  def initialize
    @log = Log.new
  end

  def redirected_link(url)
    text = %x[curl -I -L "#{url}"]
    text.scan(/Location: ([^\n]+)/).flatten.last.to_s.chomp
  end

  def redirected_file(url)
    text = %x[curl -I -L "#{url}"]
    redirect = text.scan(/Location: ([^\n]+)/).flatten
    #redirect = text.scan(/^HTTP\/1.1 (\w*).*\n.*\n.*\n.*\n.*\n.*\n.*\n.*\n.*\n.*\n.*\nLocation: ([^\n]+)/)
    case redirect.count
      when 0..3 then
        a = []
        redirect.each {|s|
          a << s.chomp
        }
        a
      when 4 then
        redirected_link(url)
      else
        a = []
    end

  end

  def code_state(host)
    text = %x[curl --head "#{host}"]
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
    #unless page.nil?
    if page.code == "200"
      Nokogiri::HTML(page.body)
    end
  end

  def page_search_fs
    pages = []
    (0..40).each { |p|
      if p == 0
        pages << [p,'http://fs.to/video/films/?sort=new']
      else
        pages << [p,'http://fs.to/video/films/?sort=new&page='"#{p}"'']
      end
    }
    pages
  end

  def fs_url_video(html)
    h = html.at('body').inner_text
    uri = h.scan(/'\/(get)\/(dl)\/(\w*)\/(.*)/).join("/").delete("',").chomp
    "http://fs.to/" + uri
  end

  def fs_page_video(url)
    p = url.split('/')
    hash = p[5].split('-')
    return  "http://fs.to/view/#{hash[0]}"
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

  def fs_url_resolution(url)
    @log.logs url
    h = {}
    d = nokogiri url
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

  def get_search_html_fs(url=page_search_fs)
    h = {}
    threads = []
    url.each do |host|
      threads << Thread.new do
        video = []
        doc = nokogiri host[1]
        section = doc.css("div.b-poster-section a")
        section.each{|link|
          f = {}
          f['date'] =  link.css("b.date").text.delete("\n")
          f['prev'] = "http://fs.to" + link['href']
          f['page_video'] = fs_page_video(f['prev'])
          f['url'] = "http://fs.to" + redirected_link(f['page_video'])
          f['audio'] = fs_url_sound(nokogiri(f['url']))

          d = nokogiri f['prev']
          d.search("div.b-tab-item").each{|div|

            div.search("div.head__title h1").each{|h1|
              f['name']  = h1.text.delete("\n").delete("\t")}

            div.search("div.poster-main a img").each{|img|
              f['image'] = img["src"]}

            genre = div.search("div.item-info tr")[0]
              f["genre"] = genre.css("td")[1].text.delete("\n")

            year = div.search("div.item-info tr")[1]
              f["year"] = year.css("td")[1].text.delete("\n")

            country = div.search("div.item-info tr")[2]
              f["country"] = country.css("td")[1].text.delete("\n")

            producer = div.search("div.item-info tr")[3]
              f["producer"] = producer.css("td")[1].text.delete("\n")

            cast = div.search("div.item-info tr")[4]
              f["cast"] = cast.css("td")[1].text.delete("\n")

            notice = div.search("div.item-info p")
              f["notice"] = notice.text.delete("\n")
          }

          video << f
        }
        h[host[0]]= video
      end
    end
    threads.each(&:join)
    h.sort
  end

end

