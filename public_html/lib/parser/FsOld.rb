# encoding: utf-8
class Fsparsertread

  def initialize
    @box = []
  end

  def get_pages_films(p_start=0, p_end=50)
    films_link = get_films_link(p_start, p_end)
    @box << films_link
    if p_end+1 > 50
      return  @box
    else
      get_pages_films(p_start + 50, p_end+50)
    end
  end

  def get_films_link(p_start, p_end)
    url =  page_search_fs(p_start, p_end)
    h = {}
    threads = []
    url.each do |host|
      threads << Thread.new {
        i = 1
        films = []
        doc = nokogiri host[1]                                       #http://fs.to/video/films/?sort=new&page=1
        if doc
          section = doc.css("div.b-poster-section a")
          section.each { |link|
            film = {}
            film['num_film'] = i
            film['date'] =  link.css("b.date").text.delete("\n")
            film['prev'] = "http://fs.to" + link['href']           #http://fs.to/video/films/i109rbr9tpMFWMdNcVRheM-effekt-kolibri.html
            film['page_video'] = fs_page_video(film['prev'])       #http://fs.to/view/i109rbr9tpMFWMdNcVRheM
            film['all_description'] = get_film_description(film['prev'])
            film['audio'] = get_film_audio(film['page_video'])
            films << film
            i +=1
          }
          h[host[0]] = films
        else
          h[host[0]] = "ERROR_get_films_link=#{host[1]}"
        end
      }
    end
    threads.each(&:join)
    return Hash[h.sort]
  end

  def get_film_audio(page_video)
    f = {}
    h = {}
    u_redirect = redirected_page(page_video)
    unless u_redirect.nil?
      html =  nokogiri("http://fs.to/" + u_redirect)
      unless html.nil?
        html.css("div.m-sound li a").each{|link|
          audio = link['href'].scan(/audio_language=([а-яА-я]*)&translate=([а-яА-я]*)&translation=([а-яА-я]*)/)
          url ="http://fs.to" + link['href']
          redirect = redirected_page(url)
          unless redirect.nil?
            url = "http://fs.to" + redirect
            res = fs_url_resolution(url)
            h[audio[0]] = res
          else
            h[audio[0]] = "3-ERROR_get_film_audio=#{url}"
          end
        }
        f['url']  = "http://fs.to/" + u_redirect
        f['resolution'] = h
      else
        f['url']  =  "2-ERROR_get_film_audio=#{u_redirect}"                                #http://fs.to/view/i109rbr9tpMFWMdNcVRheM?play&file=1972681
        f['resolution'] = nil
      end
    else
      f['url'] = "1-ERROR_get_film_audio=#{page_video}"                         #http://fs.to/view/i109rbr9tpMFWMdNcVRheM
      f['resolution'] = nil
    end



    return f
  end

  def fs_url_resolution(url)
    h = {}
    d = nokogiri url
    if d
      d.css("div.m-quality li a").each{|link|
        l ="http://fs.to" + link['href']
        redirect = redirected_file(l)
        unless redirect.nil?
          u = "http://fs.to" + redirect.chomp
          p = page(u)
          begin
            uri = p.body.scan(/'\/(get)\/(dl)\/(\w*)\/(.*)/).join("/").delete("',")
          rescue NoMethodError
            @log.logs(redirect)
          ensure
            h[link.text] = ['NoMethodError',u]
          end
          http =  "http://fs.to/" + uri.chomp
          play = redirected_file(http)
          unless play.nil?
            a =[]
            a << u
            a << play.chomp
            h[link.text] = a
          end

        else
          @log.logs(['RESOLUTION_ERROR',l])
          h[link.text] = ['RESOLUTION_ERROR',l,nil]
        end
      }
    else
      @log.logs(['ERROR',url])
      h['ERROR'] = url
    end

    return h
  end

  def get_film_description(prev)
    f = {}
    d = nokogiri prev
    if d
      d.search("div.b-tab-item").each do |div|
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
      end
    else
      f["ERROR_get_films_link"] = prev
    end
    return f
  end

  def page_search_fs(p_st, p_en)
    pages = []
    (p_st..p_en).each { |p|
      if p == 0
        pages << [p,'http://fs.to/video/films/?sort=new']
      else
        pages << [p,'http://fs.to/video/films/?sort=new&page='"#{p}"'']
      end
    }
    pages
  end

  def fs_page_video(url)
    p = url.split('/')
    hash = p[5].split('-')
    return  "http://fs.to/view/#{hash[0]}"
  end

  def redirected_page(url)
    text = %x[curl -I -L "#{url.delete(' ')}"]
    redirect = text.scan(/Location: ([^\n]+)/).flatten
    unless redirect.empty?
      redirect.last.to_s.chomp
    else
      nil
    end
  end

  def redirected_file(url)
    text = %x[curl -I -L "#{url.delete(' ')}"]
    redirect = text.scan(/Location: ([^\n]+)/).flatten
    unless redirect.empty?
      redirect.last.to_s.chomp
    else
      nil
    end
  end

  def nokogiri(url)
    page = self.page(url)
    unless page.nil?
      Nokogiri::HTML(page.body)
    else
      nil
    end
  end

  def page(url)
    begin
      uri = URI(url)
      Net::HTTP.get_response(uri)
    rescue
    end
  end


end







