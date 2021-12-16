namespace :check do

  desc 'Check EAD data'
  task :ead => :environment do |t, args|
    require 'import/ead'
    require 'csv'

    totals = Ead::Importer.check(args.extras)

    unless totals.empty?
      puts "Check finished: "
      #totals.map {|filename, stats| puts "\nFound the following in #{filename}"; stats.map {|k,v| puts "#{k} => #{v}\n"} }
      CSV.open("/var/tmp/ead_stats.csv", "wb") {|csv|  csv << totals[0].keys; totals.each {|stats| csv << stats.values} }
    end
  end


  desc 'Check SIRSI data'
  task :sirsi => :environment do |t, args|
    require 'import/sirsi'
    require 'csv'

    totals = Sirsi::Importer.check(args.extras)
    puts totals
    unless totals.empty?
      puts "Check finished: "
      totals[0].map{ |key, total| puts "#{key} => #{total}"}
      CSV.open("/var/tmp/sirsi_stats.csv", "wb") {|csv|  csv << totals[0].keys; totals.each {|stats| csv << stats.values} }

    end
  end

end
