# encoding: utf-8
class Fsparsertread

  attr_reader :films_link

  def initialize
    @box = []
    @i = 1
    @page = 0
  end

  def get_films_pereparser(p_start, p_end)
    url =  page_search_fs(p_start, p_end)
    h = {}
    threads = []
    url.each do |host|
      threads << Thread.new {
        films = []
        doc = nokogiri host[1]                                       #http://fs.to/video/films/?sort=new&page=1
        if doc
          section = doc.css("div.b-poster-section a")
          section.each { |link|
            film = {}
            film['date'] =  link.css("b.date").text.delete("\n")
            film['prev'] = "http://fs.to" + link['href']           #http://fs.to/video/films/i109rbr9tpMFWMdNcVRheM-effekt-kolibri.html
            film['page_video'] = fs_page_video(film['prev'])       #http://fs.to/view/i109rbr9tpMFWMdNcVRheM
            film['all_description'] = get_film_description(film['prev'])
            films << film
          }
          h[host[0]] = films
        else
          h['ERROR'] = ['get_films_link(nokogiri)',host[0], host[1]]
        end
      }
    end
    threads.each(&:join)
    return Hash[h.sort]
  end

  def get_pages_films(p_start = 0, p_end = 10, count = 10, hop = 10)
    films_link = get_films_link(p_start, p_end)
    @box << films_link
    if p_end+1 > count
      return  @box
    else
      get_pages_films(p_start + hop, p_end + hop)
    end
  end

  def get_films_link(p_start, p_end)
    url =  page_search_fs(p_start, p_end)
    h = {}
    threads = []
    url.each do |host|
      threads << Thread.new {
        films = []
        doc = nokogiri host[1]                                       #http://fs.to/video/films/?sort=new&page=1
        if doc
          section = doc.css("div.b-poster-section a")
          section.each { |link|
            film = {}
            film['date'] =  link.css("b.date").text.delete("\n")
            film['prev'] = "http://fs.to" + link['href']           #http://fs.to/video/films/i109rbr9tpMFWMdNcVRheM-effekt-kolibri.html
            film['page_video'] = fs_page_video(film['prev'])       #http://fs.to/view/i109rbr9tpMFWMdNcVRheM
            film['all_description'] = get_film_description(film['prev'])
            film['audio'] = get_film_audio(film['page_video'])
            films << film
          }
          h[host[0]] = films
        else
          h['ERROR'] = ['get_films_link(nokogiri)',host[0], host[1]]
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
          location = "http://fs.to/" + u_redirect
          html =  nokogiri(location)
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

                f = {['3-ERROR_get_film_audio'] => [url]}
              end
            }
            f = h
          else

            f = {['2-ERROR_get_film_audio'] => [location]}
          end
        else

          f = {["1-ERROR_get_film_audio"] => [page_video]}
        end

    return f
  end

  def fs_url_resolution(url)
    h = {}
    d = nokogiri url
    if d
      d.css("div.m-quality li a").each{|link|
        l ="http://fs.to" + link['href']
        redirect = redirected_page(l)
        unless redirect.nil?
          u = "http://fs.to" + redirect
          p = page(u)
          unless p.nil?
            uri = p.body.scan(/'\/(get)\/(play)\/(\w*)/).join("/").delete("',")
            http =  "http://fs.to/" + uri.chomp + ".mp4"
            play = redirected_page(http)
            unless play.nil?
              a =[]
              a << u
              a << play
              h[link.text] = a
            else

              h = {'4-ERROR_fs_url_resolution' => [u]}
            end
          else

            h = {'3-ERROR_fs_url_resolution' => [u]}
          end
        else

          h = {'2-ERROR_fs_url_resolution' => [l]}
        end
      }
    else

      h = {'1-ERROR_fs_url_resolution' => [url]}
    end
    return h
  end

  def get_film_description(prev)
    f = {}
    d = nokogiri prev
    if d
      d.search("div.b-tab-item").each do |div|

        div.search("div.head__title h1").each{|h1|
          f['name']  = h1.text.delete("\n").delete("\t")
        }

        div.search("div.poster-main a img").each{|img|
          f['image'] = img["src"]
        }

        f[prev] = prev

        begin
        genre = div.search("div.item-info tr")[0]
          f["genre"] = genre.css("td")[1].text.delete("\n")
        rescue
          f["genre"] = nil
        end

        begin
        year = div.search("div.item-info tr")[1]
          f["year"] = year.css("td")[1].text.delete("\n")
        rescue
          f["year"] = nil
        end

        begin
        country = div.search("div.item-info tr")[2]
          f["country"] = country.css("td")[1].text.delete("\n")
        rescue
          f["country"] = nil
        end

        begin
        producer = div.search("div.item-info tr")[3]
          f["producer"] = producer.css("td")[1].text.delete("\n")
        rescue
          f["producer"] = nil
        end

        begin
        cast = div.search("div.item-info tr")[4]
          f["cast"] = cast.css("td")[1].text.delete("\n")
        rescue
          f["cast"] = nil
        end

        begin
        notice = div.search("div.item-info p")
          f["notice"] = notice.text.delete("\n")
        rescue
          f["notice"] = nil
        end

      end
    else
      f["ERROR_get_film_description"] = prev
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
    text = %x[curl --max-time 200 -I -L "#{url.delete(' ')}"]
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






