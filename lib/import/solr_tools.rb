# Load the concerns first
concerns_dir = File.join(File.dirname(__FILE__), 'concerns')
Dir[File.join(concerns_dir, '**', '*.rb')].each do |file|
  require file
end

Dir[File.join(File.dirname(__FILE__), '**', '*.rb')].each do |file|
  require file
end

module SolrTools

  # Update solr doc with exacetly the same info as is already in the solr doc (i.e. reindex)
  def self.reindex(q=nil, rows=nil, fq=nil)
    @q=q
    @rows=rows
    @fq=fq
    @solr = Blacklight.default_index.connection
    get_solr_docs_with_query.each{|doc| update_doc doc['id'], doc }
  end

  def self.update(q=nil, rows=nil, update=nil, with=nil)
    @q=q
    @rows=rows
    @solr = Blacklight.default_index.connection
    result=get_solr_docs_with_query
    total = result.count
    i=0
    result.each do |doc| 
      if doc[update].blank?
        update_query = "{'id':'#{doc['id']}', #{update} :{'set':'#{doc[with]}'}}"
        op=`curl -s 'http://localhost:8983/solr/blacklight-core/update?commit=true' -H 'Content-type:application/json' -d "[#{update_query}]"`
        i+=1
        print "#{i}/#{total}\r"
      end
    end
  end

  def self.get_solr_docs_with_query
    query_params = {q: @q, rows: @rows}
    query_params['fq'] = @fq if @fq.present?
    @solr.get('select', params: query_params)['response']['docs']
  end

  def self.update_doc(id,attributes)
    # remove non-reindexable attributes
    attributes.delete('_version_')
    attributes.delete('score')
    # Assumption here is that we don't ant to update timestamp on reindex, but if this is not the case uncoment below
    # attributes.delete('timestamp')
    puts "Re-indexing #{id}"
    @solr.add(attributes)
    @solr.commit
  end

end

