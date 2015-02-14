# encoding: utf-8

class Controller  <  BaseController

  def index
    f_video = []
    films = Films.all.limit(7).offset(0)
    films.each do |v|
      video = {}
      video['prev'] = v.prev.force_encoding("UTF-8")
      video['page_video'] = v.page_video.force_encoding("UTF-8")
      video['name']  = v.name.force_encoding("UTF-8")
      video['image'] = v.image.force_encoding("UTF-8")
      video["genre"] = v.genre.force_encoding("UTF-8")
      video["year"] = v.year.force_encoding("UTF-8")
      video["country"] = v.country.force_encoding("UTF-8")
      video["producer"] = v.producer.force_encoding("UTF-8")
      video["cast"] = v.cast
      video["notice"] = v.notice.force_encoding("UTF-8")
      h={}
      audio = v.audio.to_a
      unless audio.empty?
        audio.each do |a|
          unless  a.quality.force_encoding("UTF-8") ==  "4-ERROR_fs_url_resolution"
            name = a.name.force_encoding("UTF-8")
            video["translit"] = a.translit.force_encoding("UTF-8")
            if name.include? "Русский"
              video["translit"] = a.translit.force_encoding("UTF-8")
            end
            q = {a.quality.force_encoding("UTF-8") => [a.translit.force_encoding("UTF-8"),a.play.force_encoding("UTF-8") ]}
            h[name + ": " + a.quality.force_encoding("UTF-8")] = q
          end
        end
        Films.clear_active_connections!
        Audio.clear_active_connections!
        # else
        #   audio_resolution(v)
        #   Films.clear_active_connections!
        #   Audio.clear_active_connections!
        #   films(a_page)
      end
      video["audio"] = h
      f_video << video
    end

    return view("site/tmp/page/index.erb", {
        "active"=>"/",
        "title" => "Главная - beegoo.net",
        'videos' => f_video,
        "keywords" => "Смотреть, Сериалы, Фильмы, Кино, Онлайн, Мультфильмы, Мультсериалы.",
        "description" => "beegoo.net - сайт фильмов, мультфильмов и сериалов."
    })
  end

  def films(a_page = nil)
    p = Pagination.new
    p.model='Films'
    unless a_page
     @req.params["page_active"] ? a_page = @req.params["page_active"].to_i : a_page = 0
    end
    p.active_page = a_page
    films = p.pagination
    Films.clear_active_connections!
    Audio.clear_active_connections!
    unless films.empty?
      f_video = []
      films.each do |v|
        video = {}
        h={}
        audio = v.audio.to_a
        unless audio.empty?
         unless audio[0].translit.nil? && audio.count == 1


          audio.each do |a|
            unless  a.quality.force_encoding("UTF-8") ==  "4-ERROR_fs_url_resolution"
              name = a.name.force_encoding("UTF-8")
              video["translit"] = a.translit.force_encoding("UTF-8")
              if name.include? "Русский"
                video["translit"] = a.translit.force_encoding("UTF-8")
              end
              q = {a.quality.force_encoding("UTF-8") => [a.translit.force_encoding("UTF-8"),a.play.force_encoding("UTF-8") ]}
              h[name + ": " + a.quality.force_encoding("UTF-8")] = q
            end
          end

          video['prev'] = v.prev.force_encoding("UTF-8")
          video['page_video'] = v.page_video.force_encoding("UTF-8")
          video['name']  = v.name.force_encoding("UTF-8")
          video['image'] = v.image.force_encoding("UTF-8")
          video["genre"] = v.genre.force_encoding("UTF-8")
          video["year"] = v.year.force_encoding("UTF-8")
          video["country"] = v.country.force_encoding("UTF-8")
          video["producer"] = v.producer.force_encoding("UTF-8")
          video["cast"] = v.cast
          video["notice"] = v.notice.force_encoding("UTF-8")
          Films.clear_active_connections!
          Audio.clear_active_connections!

         end


        end
        video["audio"] = h
        f_video << video
      end
    end


    new_video = []
    films = Films.joins("LEFT JOIN `audios` ON audios.films_id = films.id WHERE audios.films_id IS NOT null").order('created_at DESC').select("DISTINCT films.*").limit(7).offset(0)
    films.each do |v|
      video = {}
      video['prev'] = v.prev.force_encoding("UTF-8")
      video['page_video'] = v.page_video.force_encoding("UTF-8")
      video['name']  = v.name.force_encoding("UTF-8")
      video['image'] = v.image.force_encoding("UTF-8")
      video["genre"] = v.genre.force_encoding("UTF-8")
      video["year"] = v.year.force_encoding("UTF-8")
      video["country"] = v.country.force_encoding("UTF-8")
      video["producer"] = v.producer.force_encoding("UTF-8")
      video["cast"] = v.cast
      video["notice"] = v.notice.force_encoding("UTF-8")
      h={}
      audio = v.audio.to_a
      unless audio.empty?
        audio.each do |a|
          unless  a.quality.force_encoding("UTF-8") ==  "4-ERROR_fs_url_resolution"
            name = a.name.force_encoding("UTF-8")
            video["translit"] = a.translit.force_encoding("UTF-8")
            if name.include? "Русский"
              video["translit"] = a.translit.force_encoding("UTF-8")
            end
            q = {a.quality.force_encoding("UTF-8") => [a.translit.force_encoding("UTF-8"),a.play.force_encoding("UTF-8") ]}
            h[name + ": " + a.quality.force_encoding("UTF-8")] = q
          end
        end
        Films.clear_active_connections!
        Audio.clear_active_connections!
        # else
        #   audio_resolution(v)
        #   Films.clear_active_connections!
        #   Audio.clear_active_connections!
        #   films(a_page)
      end
      video["audio"] = h
      new_video << video
    end


    Films.clear_active_connections!
    Audio.clear_active_connections!
    return view("site/tmp/page/films.erb", {
        'active'=>'/films',
        'title' => 'Фильмы - beegoo.net',
        'videos' => f_video,
        'new_video' => new_video,
        'pagination' => p.paging,
        "keywords" => "Фильмы, Онлайн",
        "description" => "Смотреть и скачать бесплатно фильмы, мультфильмы и сериалы онлайн в хорошем качестве",
        'test' => p.cou
    })
  end

  def play
    a = Audio.find_by(:translit => @req.params["play"])
    Films.clear_active_connections!
    Audio.clear_active_connections!
    f = a.films
    track = f.audio.to_a
    Audio.clear_active_connections!
    Films.clear_active_connections!
    return view("site/tmp/page/play.erb", {
        'active'=>'/films',
        'test' => '',
        'title' => "#{f.name} - beegoo.net",
        'film_info' => f,
        'play' => a.play,
        'track' => track,
        'keywords' => 'Фильм, Онлайн',
        'description' => 'Смотреть и скачать бесплатно фильмы, мультфильмы и сериалы онлайн в хорошем качестве'
    })
  end

  def serials
    return view("site/tmp/page/serials.erb", {
        "active"=>"/serials",
    })
  end

  def parser_page_films(start=0, count=0)
    t = Translit.new
    fs = Fs.new
    fs.parser_page_films(start, count)
    fs.pg.each do |video|
      f = Films.find_by(:name=> video['name'])
      Films.clear_active_connections!
      Audio.clear_active_connections!
      unless f
        f= Films.create(
            :prev =>video["prev"],
            :page_video =>video["page_video"],
            :name =>video["name"],
            :image => video["image"],
            :genre => video["genre"],
            :year => video["year"],
            :country => video["country"],
            :producer => video["producer"],
            :cast => video["cast"],
            :notice =>video["notice"],
            :date =>video["date"]
        )
        video["audio"].each do |key, value|
          value.each {|quality, url|
            if video["name"]
              text = video["name"].force_encoding("UTF-8") + key.to_s + quality
              tr = t.convert(text.mb_chars.downcase.to_s)
            else
              tr = 'NONAME'
            end
            f.audio.create(:translit => tr, :name =>key.to_s, :quality =>quality, :url => url[0], :play => url[1])
            Films.clear_active_connections!
            Audio.clear_active_connections!
          }
        end
      else
        video["audio"].each do |key, value|
          value.each {|quality, url|
            if video["name"]
              text = video["name"].force_encoding("UTF-8") + key.to_s + quality
              tr = t.convert(text.mb_chars.downcase.to_s)
            else
              text = 'NONAME' + key.to_s + quality
              tr = t.convert(text.mb_chars.downcase.to_s)
            end
            a = Audio.find_by(:translit => tr)
            unless a
              f.audio.create(:translit => tr, :name =>key.to_s, :quality =>quality, :url => url[0], :play => url[1])
            end
            Films.clear_active_connections!
            Audio.clear_active_connections!
          }
        end
      end
    end
    if count < 3
      parser_page_films(start+1, count+1)
    else
      return view("site/tmp/page/parser_page_films.erb", {
          "title" => "Парсер",
          "test" => fs.test,
          "videos" => fs.pg,
          "time"  => ''
      })
    end
  end

  def search
    f =  Films.where("name LIKE '%#{@req.params["search_base"]}%'").to_a
    unless f.empty?
      f_video = []
      f.each do |v|
        video = {}
        video['prev'] = v.prev.force_encoding("UTF-8")
        video['page_video'] = v.page_video.force_encoding("UTF-8")
        video['name']  = v.name.force_encoding("UTF-8")
        video['image'] = v.image.force_encoding("UTF-8")
        video["genre"] = v.genre.force_encoding("UTF-8")
        video["year"] = v.year.force_encoding("UTF-8")
        video["country"] = v.country.force_encoding("UTF-8")
        video["producer"] = v.producer.force_encoding("UTF-8")
        video["cast"] = v.cast.force_encoding("UTF-8")
        video["notice"] = v.notice.force_encoding("UTF-8")
        h={}
        v.audio.to_a.each do |a|
          name = a.name.force_encoding("UTF-8")
          video["translit"] = a.translit.force_encoding("UTF-8")
          if name.include? "Русский"
            video["translit"] = a.translit.force_encoding("UTF-8")
          end
          q = {a.quality.force_encoding("UTF-8") => [a.translit.force_encoding("UTF-8"),a.play.force_encoding("UTF-8") ]}
          h[name + ": " + a.quality.force_encoding("UTF-8")] = q
        end
        video["audio"] = h
        f_video << video
      end
    else
      f_video = {}
    end
    return view("site/tmp/page/search.erb", {
        "active"=>"/films",
        "title"=>"Результаты поиска - beegoo.net",
        "videos" => f_video,
        "test" => ''
    })
  end

  def film_error
    t = Translit.new
    fs = Fs.new
    f = Films.all
    Films.clear_active_connections!
    f.each do |v|
      prev = v.prev.force_encoding("UTF-8")
      unless v.name
        video = fs.film_error_name(prev)
        Films.update(v.id, :name => video["name"],
                     :image => video["image"],
                     :genre => video["genre"],
                     :year  => video["year"],
                     :country => video["country"],
                     :producer => video["producer"],
                     :cast => video["cast"],
                     :notice => video["notice"]
        )
        Films.clear_active_connections!
        Audio.clear_active_connections!
      end
    end

=begin
    t = Translit.new
    fs = Fs.new
    f = Films.all
    Films.clear_active_connections!
    Audio.clear_active_connections!
    f.each do |v|
      audio = v.audio.to_a
      unless audio.empty?
        audio.each do |value|
         code = fs.code_status(value.play)
          unless code == '200'
           url = value.url.force_encoding("UTF-8")
           sound = fs.fs_url_sound_one(url)
           Audio.update(value.id, :play => sound )
          end
        end
      end
    end
=end

    t = Translit.new
    fs = Fs.new
    a = []
    f = Films.all
    Films.clear_active_connections!
    Audio.clear_active_connections!
    f.each do |v|
      film = {}
      audio = v.audio.to_a
      if audio.empty?
        name = v.name.force_encoding("UTF-8")
        page_video = v.page_video.force_encoding("UTF-8")
        sound = fs.film_error_video(page_video)
        film['audio'] = sound
        sound.each {|key, value|
          value.each {|quality, url|
            text = name.force_encoding("UTF-8") + key.to_s + quality
            tr = t.convert(text.mb_chars.downcase.to_s)
            add = Films.find_by(:name=> name)
            add.audio.create(:translit => tr, :name =>key.to_s, :quality =>quality, :url => url[0], :play => url[1])
            a << film
            Films.clear_active_connections!
            Audio.clear_active_connections!
          }
        }
      end
    end
    return view("site/tmp/page/film_error.erb", {
        "test" => '',
        "video" => a
    })
  end

  def parser_films(p_start=0, p_end=10)
    time={}
    time['start'] = Time.new
    t = Translit.new
    fs = Fsparsertread.new
    films = fs.get_films_link(p_start, p_end)
    time['end'] = Time.new
    time['time'] = time['end'] - time['start']

    films.each do |key,value|
      unless key == 'ERROR'

        value.each do |video|
          unless video['all_description']['ERROR_get_film_description']

            audio_error = []

            video['audio'].each do |key, value|
              if key.to_s.include?("ERROR_get_film_audio")
                audio_error = [key, value]
              end
              value.each do |key, value|
                if key.to_s.include?("ERROR_fs_url_resolution")
                  audio_error = [key, value]
                end
              end
            end

            if audio_error.empty?
              f = Films.find_by(:name=> video['all_description']['name'])
              unless f
                f= Films.create(
                    :prev =>video["prev"],
                    :page_video =>video["page_video"],
                    :name =>video["all_description"]["name"],
                    :image => video["all_description"]["image"],
                    :genre => video["all_description"]["genre"],
                    :year => video["all_description"]["year"],
                    :country => video["all_description"]["country"],
                    :producer => video["all_description"]["producer"],
                    :cast => video["all_description"]["cast"],
                    :notice =>video["all_description"]["notice"],
                    :date =>video["date"]
                )
                video["audio"].each do |key, value|
                  value.each do |quality, url|
                    text = video["all_description"]["name"].force_encoding("UTF-8") + key.to_s + quality
                    tr = t.convert(text.mb_chars.downcase.to_s)
                    f.audio.create(:translit => tr, :name =>key.to_s, :quality =>quality, :url => url[0], :play => url[1])
                  end
                end
                Films.clear_active_connections!
                Audio.clear_active_connections!
              else
              end

              @array << video


            else
              Error.create(:error =>audio_error[0].to_s,:url =>audio_error[1].to_s)
            end

          else
            Error.create(:error =>'all_description',:url =>video['all_description']['ERROR_get_film_description'])
          end
        end


      else
        Error.create(:error =>'ERROR',:url =>value.to_s)
      end
    end



    unless p_end+1 > 700
      parser_films(p_start+10, p_end+10)
    else
      return view("site/tmp/page/parser_films.erb", {
          "test" => @array,
          "time" => time
      })
    end
  end

  def pereparser(p_start=0, p_end=10)
    t = Translit.new
    fs = Fsparsertread.new
    films = fs.get_films_pereparser(p_start, p_end)
    films.each do |key,value|
      unless key == 'ERROR'
        value.each do |video|
          unless video['all_description']['ERROR_get_film_description']

            f = Films.find_by(:name=> video['all_description']['name'])
            Films.clear_active_connections!
            Audio.clear_active_connections!
            unless f
              f= Films.create(
                  :prev =>video["prev"],
                  :page_video =>video["page_video"],
                  :name =>video["all_description"]["name"],
                  :image => video["all_description"]["image"],
                  :genre => video["all_description"]["genre"],
                  :year => video["all_description"]["year"],
                  :country => video["all_description"]["country"],
                  :producer => video["all_description"]["producer"],
                  :cast => video["all_description"]["cast"],
                  :notice =>video["all_description"]["notice"],
                  :date =>video["date"]
              )
              Films.clear_active_connections!
              Audio.clear_active_connections!
            end
          else
            file = File.open('logs.txt' , 'a')
            file.puts(video['all_description']['ERROR_get_film_description'].to_s)
            file.close
          end
        end
      else
        file = File.open('logs.txt' , 'a')
        file.puts(value.to_s)
        file.close
      end
    end

    unless p_end+1 > 10
      pereparser(p_start+10, p_end+10)
    else
      Films.clear_active_connections!
      Audio.clear_active_connections!
      return view("site/tmp/page/parser_films.erb", {
          "test" => @array
      })
     #film_null
     #parser_audio
    end
  end

  def parser_audio(off = 0)
    t = Translit.new
    fs = Fsparsertread.new
    audio_f = {}

    threads = []
    f = Films.all.order('created_at DESC').limit(10).offset(off)
    f.each do |film|
      audio = film.audio.to_a
      if audio.empty?
      threads << Thread.new {
          audio_f[[film.name.force_encoding("UTF-8"),film.id]] = fs.get_film_audio(film.page_video)
       }
      end
    end
    threads.each(&:join)


    unless audio_f.empty?
      audio_f.each do |k,v|
        v.each do |key, value|
          unless key == "0-ERROR_get_film_audio"
            value.each {|quality, url|
              text = k[0].force_encoding("UTF-8") + key.to_s + quality
              tr = t.convert(text.mb_chars.downcase.to_s)
              Audio.create(:films_id=>k[1], :translit => tr, :name =>key.to_s, :quality =>quality, :url => url[0], :play => url[1])
              Films.clear_active_connections!
              Audio.clear_active_connections!
            }
          else
            Audio.create(:films_id=>k[1], :translit => 'ERROR', :name =>'ERROR', :quality =>'ERROR', :url =>'ERROR', :play =>'ERROR')
            Films.clear_active_connections!
            Audio.clear_active_connections!
          end
        end
      end
     end

    unless off+1 > 3000
      parser_audio(off+10)
    else
      return view("site/tmp/page/parser_audio.erb", {
          "test" => audio_f
      })
    end
  end

  def film_null
    t = Translit.new
    fs = Fsparsertread.new
    films = Films.where({:name => nil})
    films.each { |f|
      video = fs.get_film_description(f.prev)
      Films.update(f.id,
                   :name => video["name"],
                   :image => video["image"],
                   :genre => video["genre"],
                   :year  => video["year"],
                   :country => video["country"],
                   :producer => video["producer"],
                   :cast => video["cast"],
                   :notice => video["notice"]
      )
    }

    test =[]
    audio = Audio.where({:play => nil})
    audio.each { |a|
      films = Films.find(a.films_id)
      a.destroy
      audio_resolution(films)
      test << films.name
    }


    return view("site/tmp/page/film_null.erb", {
        "test" => test
    })
  end

  def audio_resolution(film)
    Films.clear_active_connections!
    Audio.clear_active_connections!
    t = Translit.new
    fs = Fsparsertread.new
        a = fs.get_film_audio(film.page_video)
        a.each do |key, value|
         unless key == "0-ERROR_get_film_audio"
          value.each {|quality, url|
            text = film.name.force_encoding("UTF-8") + key.to_s + quality
            tr = t.convert(text.mb_chars.downcase.to_s)
            film.audio.create(:translit => tr, :name =>key.to_s, :quality =>quality, :url => url[0], :play => url[1])
            Films.clear_active_connections!
            Audio.clear_active_connections!
          }
         else
           film.audio.create(:translit => nil, :name =>nil, :quality =>nil, :url =>nil, :play =>nil)
         end
        end
  end

  def new_resolution
    test = {}
    audio_array = []
    t = Translit.new
    fs = Fsparsertread.new
    #films = Films.all.limit(100).offset(0)
    films = Films.all
    films.each do |v|

      page_video = nil
      audio = v.audio.to_a
      unless audio.empty?
        audio.each do |a|
         # audios = fs.new_resolution(a.play.force_encoding("UTF-8"))
        if a.play
          text = %x[curl --max-time 200 -I -L "#{a.play.force_encoding("UTF-8").delete(' ')}"]
          code = text.scan(/HTTP\/1.1 (\d*)/).flatten
          if code[0] != "200" || code.empty?
            page_video = v.page_video.force_encoding("UTF-8")
            a.destroy
          else
            audio_array << a.translit.force_encoding("UTF-8")
          end
        end

        end
      end


      if page_video
      a = fs.get_film_audio(page_video)
      a.each do |key, value|
        unless key == "0-ERROR_get_film_audio"
          value.each do|quality, url|

            text = v.name.force_encoding("UTF-8") + key.to_s + quality
            tr = t.convert(text.mb_chars.downcase.to_s)

            unless audio_array.include?(tr)
              v.audio.create(:translit => tr, :name =>key.to_s, :quality =>quality, :url => url[0], :play => url[1])
              Films.clear_active_connections!
              Audio.clear_active_connections!
            end


          end
        else
          v.audio.create(:translit => nil, :name =>nil, :quality =>nil, :url =>nil, :play =>nil)
          Films.clear_active_connections!
          Audio.clear_active_connections!
        end

      end
      end
    end






    return view("site/tmp/page/new_resolution.erb", {
        "test" =>  test
    })
  end

  def test
    test = []

   # a = Films.joins(:audio).where("audios.films_id IS null")
    a = Films.joins("LEFT JOIN `audios` ON audios.films_id = films.id WHERE audios.films_id IS NOT null").select("DISTINCT films.*").limit(5)



    return view("site/tmp/page/test.erb", {
        "test" =>  a
    })
  end

end













































