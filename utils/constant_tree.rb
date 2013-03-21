# this script lists all constants hierarchycally.
# Usefull to see if what require <module> really requires.


if ARGV[0]
  require 'lims-core/' +  ARGV[0].tr(?-,?/)
elsif  __FILE__ == $0  # file ran as a script, not required by another one
  require 'lims-core'
end


def list_constants(m, name=nil, level="", done=Set.new)
  return if done.include? m
  done << m


  puts "#{level}- #{name || m} (#{m.class})"
  if m.respond_to?(:constants)
    m.constants.each do |n|
      c = m.const_get(n)

      next unless c.respond_to? :name
      next unless c.name.include? m.name
      list_constants(c, n, "  #{level}", done) 
    end
  end
end

list_constants(Lims::Core)
