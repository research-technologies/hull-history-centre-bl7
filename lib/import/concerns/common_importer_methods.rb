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
