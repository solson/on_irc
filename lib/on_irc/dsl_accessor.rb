class Module
  # taken from http://www.artima.com/rubycs/articles/ruby_as_dsl3.html
  # used for the IRC.new config DSL
  def dsl_accessor(*symbols)
    symbols.each do |sym|
      class_eval %{
        def #{sym}(*val)
          if val.empty?
            @#{sym}
          else
            @#{sym} = val.size == 1 ? val[0] : val
          end
        end
      }
    end
  end
  
  def bool_dsl_accessor(*symbols)
    symbols.each do |sym|
      class_eval %{
        def #{sym}(val = true)
          @#{sym} = !!val
        end
        
        def #{sym}?
          !!@#{sym}
        end
      }
    end
  end
end
