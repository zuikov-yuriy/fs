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







