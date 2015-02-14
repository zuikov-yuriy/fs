# encoding: utf-8

class BaseController

  def initialize(req)
    @req = req
    @array = []
    @hash = {}
    @i = 0
  end

  def view(template, hash)
    @h = hash
    template = ERB.new File.new(template).read
    view = template.result(binding)
    instance_variable_set("@#{@position}".to_sym, view)
    main = ERB.new File.new("site/tmp/" + @tmp).read
    main.result(binding)
  end

  def extends(tmp, position)
     @tmp = tmp
     @position = position
     return  nil
  end

  def includes(tmp)
    template = ERB.new File.new("site/tmp/"+tmp).read
    template.result(binding)
  end

  def mb_truncate(text, length, truncate_string = "...")
    return if text.nil?
    trunc_text = length > text.size ? text : text.split(//u)[0..length].join + truncate_string
  end

  def page_not_found
    ":(;"
  end
end













=begin

    array = ['http://google.ru','http://google.ru' ]
    fib = Fiber.new do
     d = []
      array.each do |url|
        text = %x[curl --head "#{url}"]
        code = text.scan(/^HTTP\/1.1 (\w*)/)
        code = code[0].to_a
        d << code[0].to_s
      end
      Fiber.yield d
    end

    array.count.times { puts fib.resume }

    pages = %w( www.rubycentral.com slashdot.org www.google.com )
    threads = []
    for page_to_fetch in pages
      threads << Thread.new(page_to_fetch) do |url|
        text = %x[curl --head "#{url}"]
        code = text.scan(/^HTTP\/1.1 (\w*)/)
        code = code[0].to_a
        puts code[0].to_s
      end
    end





    a =[]
    fs = Fs.new
    f = Films.all.to_a
    Films.clear_active_connections!
    Audio.clear_active_connections!
    f.each do |v|
      audio = v.audio.to_a
      unless audio.empty?
        audio.each do |value|
          code = fs.code_status(value.play)
          unless code == '200'
            a << v.name.force_encoding("UTF-8")
          end
        end
      end
    end
=end

