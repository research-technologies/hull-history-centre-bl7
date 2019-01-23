namespace :import do

  desc 'Import EAD data'
  task :ead => :environment do |t, args|
    require 'import/ead'

    errors = Ead::Importer.import(args.extras)

    unless errors.empty?
      puts "Import finished with the following errors: "
      errors.map {|e| puts "\n"; puts e }
    end
  end


  desc 'Import SIRSI data'
  task :sirsi => :environment do |t, args|
    require 'import/sirsi'

    errors = Sirsi::Importer.import(args.extras)

    unless errors.empty?
      puts "Import finished with the following errors: "
      errors.map {|e| puts "\n"; puts e }
    end
  end

end
