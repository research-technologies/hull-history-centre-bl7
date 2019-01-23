module IdFormatter

  def format_id(raw_id)
    return unless raw_id
    raw_id.gsub(' ', '-').gsub('/', '-')
  end

  # This method will return 'U DMU/1/154' from 'U DMU/000001/000154' to aid sorting in the interface
  # For example in default format, the identifer would sort in this order  - U DMU/1/1,  U DMU/1/10,  DMU/1/101/5/6a, and then U DMU/1/3  
  # This method will return  U DMU/000001/000001,  U DMU/000001/000010,  DMU/000001/000101/000005/000006a and U DMU/000001/000003 
  # This will result in the following correct sort order:- U DMU/1/1, U DMU/1/3 , U DMU/1/10 and DMU/1/101/5/6a
  def sortable_id(raw_id)
    return unless raw_id
    raw_id.gsub(/(\/)([0-9]+?{1,10})/, '\1000000\2').gsub(/(\/)(0+)([0-9]{6})/, '\1\3')
  end

end