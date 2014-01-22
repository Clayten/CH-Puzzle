# require "ch/puzzle/magic_watch/version"
$LOAD_PATH << (lp = File.dirname(File.realdirpath(__FILE__)))         # FIXME
%w(version magic_watch prize_cabinet guessers/non-recursive).each {|lib| fn = "#{lp}/magic_watch/#{lib}.rb" ; "Loading #{fn}" ; load fn } # using load instead of require for reloadability
