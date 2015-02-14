# encoding: utf-8

class FsT < Parser

  def initialize
    @log = Log.new
    @loc= {}
    @box = []
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
    loc = nil
    unless redirect.nil?
      loc =  redirect.last.to_s
    end
    loc
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
    #if page.code == "200"
      Nokogiri::HTML(page.body)
    else
      false
    end
  end

  def fs_page_video(url)
    p = url.split('/')
    hash = p[5].split('-')
    return  "http://fs.to/view/#{hash[0]}"
  end

  def fs_url_sound(url)
    h = {}
    html =  nokogiri(url)
    if html
        html.css("div.m-sound li a").each{|link|
          audio = link['href'].scan(/audio_language=([а-яА-я]*)&translate=([а-яА-я]*)&translation=([а-яА-я]*)/)
          l ="http://fs.to" + link['href']
          redirect = redirected_page(l)
          unless redirect.nil?
            l = "http://fs.to" + redirect
            res = fs_url_resolution(l)
            h[audio[0]] = res
          else
            @log.logs(['AUDIO_ERROR',l])
            h[audio[0]] = ['AUDIO_ERROR',l,nil]
          end
        }
    else
      h['ERROR'] = url
    end
    return h
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

  def get_search_html_fs(p_start=0, p_end=10)
    time={}
    time['start'] = Time.new
    @box << get_search(p_start, p_end)
    time['end'] = Time.new
    time['time'] = time['end'] - time['start']
    @log.logs(time)
    if p_end+1 > 10
      return  @box
    else
      get_search_html_fs(p_start + 10, p_end+10)
    end
  end

  def get_search(p_start, p_end)
    url =  page_search_fs(p_start, p_end)
    h = {}
    threads = []
    url.each do |host|
      threads << Thread.new do
        video = []
        i = 1
        doc = nokogiri host[1]
        if doc
          section = doc.css("div.b-poster-section a")
          section.each do |link|
            f = {}
            f['num_film'] = i
            f['date'] =  link.css("b.date").text.delete("\n")
            f['prev'] = "http://fs.to" + link['href']        #http://fs.to/video/films/i109rbr9tpMFWMdNcVRheM-effekt-kolibri.html
            f['page_video'] = fs_page_video(f['prev'])       #http://fs.to/view/i109rbr9tpMFWMdNcVRheM
            d = nokogiri f['prev']
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
              f['prev'] = 'ERROR'
            end
            redirect_p = redirected_page(f['page_video'])
            unless redirect_p.nil?
              f['url'] = "http://fs.to" + redirect_p  #http://fs.to/view/i109rbr9tpMFWMdNcVRheM?play&file=1972681
              f['audio'] = fs_url_sound(f['url'])
            else
              f['url'] = nil
              f['audio'] = nil
            end
            video << f
            i +=1
          end
          h[host[0]] = video
        else
          h[host[0]] = 'ERROR'
        end

      end
    end
    threads.each(&:join)
    return Hash[h.sort]
  end

end






