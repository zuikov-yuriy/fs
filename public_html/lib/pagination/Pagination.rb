class Pagination

  attr_writer :active_page, :model
  attr_reader :count, :cou

  def initialize
    @per_page =15
    @num_page = 4
  end

  def pagination
    @dc = data_count
    c = @dc/@per_page.to_i.to_f
    cnt = c.to_s.split('.')
    @count = c.to_i
    if cnt[1].to_i == 0
      @count -= 1
    end

    data(@per_page, @active_page*@per_page)
  end

  def paging
    #s = (@active_page - @num_page..@active_page).to_a.unshift('...').unshift(0) if @active_page-@num_page > 0
    #s.pop
    #e = (@active_page..@active_page + @num_page).to_a << '...' << count if @active_page+@num_page < count
    #e.shift
    s = (0..@active_page).to_a
    s.pop
    e = (@active_page..@count).to_a
    e.shift


    if s.count > 7
      ss = s[-7,7]
      ss.shift
      s = [ 0,'...', ss].flatten
    else
      s
    end


    if (@count - @active_page) > 7
      ee = e[0,7]
      ee.pop
      e = [ee, '...',@count].flatten
    else
      e
    end

    p = [@active_page-1]
    n = [@active_page + 1]


    h = Hash.new
    h['active_page'] = @active_page
    h['start'] = s
    h['end'] =  e
    h['prev']  = p
    h['next']  = n
    return h
  end

  def data(limit, offset)
     #r = eval(@model).all.order('created_at DESC').limit(limit).offset(offset)
    #r = eval(@model).all.limit(limit).offset(offset)
    r = eval(@model).joins("LEFT JOIN `audios` ON audios.films_id = films.id WHERE audios.films_id IS NOT null").select("DISTINCT films.*").limit(limit).offset(offset)

  end

  def data_count
    #r = eval(@model).all.count
    r = eval(@model).joins("LEFT JOIN `audios` ON audios.films_id = films.id WHERE audios.films_id IS NOT null").distinct.count
  end


end