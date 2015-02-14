class Log

  def initialize
    @f = file 'logs.txt'
    #@i = 0
  end

  def file(name)
    File.open(name, "w+")
  end

  def logs(data)
    file = File.open(@f , 'a')
    file.puts(data)
    file.close
  end

end
