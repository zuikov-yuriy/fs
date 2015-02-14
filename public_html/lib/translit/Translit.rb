# encoding: utf-8

class Translit

  def initialize
    @convert = {:a => 'а', :b => 'б', :v => 'в', :g =>'г', :d =>'д',
                :e => 'е', :zh => 'ж', :z =>'з', :i =>'и',
                :y => 'й', :k => 'к', :l => 'л', :m =>'м', :n =>'н',
                :o => 'о', :p => 'п', :r => 'р', :s =>'с', :t =>'т',
                :u => 'у', :f => 'ф', :kh => 'х', :tc =>'ц', :ch =>'ч',
                :sh => 'ш',:shch => 'щ',
                :ua => 'ю', :ya =>'я'
    }
  end

  def convert(text)
    tr = ''
    text.split('').each {|x|
      v = true
      @convert.each {|key, value|
        if value == x
          tr <<  key.to_s
          v = nil
        end
      }
      tr << x if v
    }
    tr.to_s.gsub('ы','i').gsub('ь','').gsub('ъ','').gsub('э','e').gsub('ё','e').scan(/\w+/).join('_')
  end

end

