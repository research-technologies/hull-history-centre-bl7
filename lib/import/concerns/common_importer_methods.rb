module CommonImporterMethods

  def import(input_files)
    errors = []
    filenames = parse_input_args(input_files)
    with_timing do
      files = Array(filenames)
      file_count = files.length

      files.each_with_index do |filename, i|
        print_message "\nImporting file #{i+1} of #{file_count}: #{filename}"
        errors << create_solr_docs_from_file_data(filename)
      end
    end
    errors = errors.flatten.compact
  end

  def check(input_files)
    errors = []
    totals = []
    filenames = parse_input_args(input_files)
    with_timing do
      files = Array(filenames)
      file_count = files.length

      files.each_with_index do |filename, i|
        print_message "\nChecking file #{i+1} of #{file_count}: #{filename}"
        totals << check_file_data(filename)
      end
    end
    errors = errors.flatten.compact
    totals
  end

  def analyse(input_files)
    errors = []
    totals = []
    filenames = parse_input_args(input_files)
    @solr_ref_nos = get_solr_ref_nos
#    @analyse_totals = {}
#    @solr_ref_nos.zip([]) { |a,b| @analyse_totals[a.to_sym] = b } 
    @analyse_totals = @solr_ref_nos.each_with_object(Hash.new(0)){|key,hash| 
#       puts "Whole key: #{key}"
#       puts "from hash with #{key.first} as key #{hash[key.first.to_sym]}"
       if hash[key.first.to_sym].is_a?(Array)
         freq_counter=hash[key.first.to_sym][0]
       else
         freq_counter=hash[key.first.to_sym]
       end
       hash[key.first.to_sym]=
       [freq_counter+1, 
       key.second ]
    }
                      
#    @titles = @solr_ref_nos.each_with_object(Hash.new("")){|key,hash| hash[key.first.to_sym]=key.second}
    
#    puts @titles
#    puts @analyse_totals
#    puts @solr_ref_nos.count
#    puts @analyse_totals.count    
    with_timing do
      files = Array(filenames)
      file_count = files.length

      files.each_with_index do |filename, i|
        print_message "\nAnalysing file #{i+1} of #{file_count}: #{filename}"
        check_file_data(filename)
      end
    end
    errors = errors.flatten.compact
    totals=@analyse_totals
    totals
  end

  def parse_input_args(input_files)
    files = Dir.glob(input_files)
    raise "#{input_files}: File Not Found" if files.empty?

    files = files.map do |file|
      if File.directory?(file)
        match_xml = File.join(file, '*.xml')
        entries = Dir.glob(match_xml)
        entries
      else
        file
      end
    end

    files.flatten
  end

  def with_timing &blk
    start_time = Time.now
    yield
    end_time = Time.now
    print_message "\nProcessing finished in: #{(end_time - start_time).ceil} seconds."
  end

  def print_message(msg)
    puts msg if verbose
  end

  def verbose
    true
  end

end
