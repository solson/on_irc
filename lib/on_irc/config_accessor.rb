# config accessors
class Module
  def config_accessor(*symbols)
    symbols.each do |sym|
      class_eval %{
        def #{sym}
          config.#{sym}
        end
        
        def #{sym}=(val)
          config.#{sym} = val
        end
      }
    end
  end
end

