namespace :analyse do

  desc 'Analyse Import EAD data with refernce to existing solr index'
  task :analyser => :environment do |t, args|
    require 'import/ead'
    require 'csv'

    totals = Analyser.analyse(args.extras)
    unless totals.empty?
      puts "Check finished: "
      #totals.map {|filename, stats| puts "\nFound the following in #{filename}"; stats.map {|k,v| puts "#{k} => #{v}\n"} }
      CSV.open("/var/tmp/analyse_stats.csv", "wb") {|csv| totals.each {|key,values| csv << [key,values].flatten } }

    end

#    unless errors.empty?
#      puts "Import finished with the following errors: "
#      errors.map {|e| puts "\n"; puts e }
#    end
  end

end
