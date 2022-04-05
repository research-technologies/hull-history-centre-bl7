namespace :solr_tools do

  desc 'Fix screwy dates'
  task :reindex, [:q, :rows, :fq] do |t, args|
    require 'import/solr_tools'
    SolrTools.reindex(args.q, args.rows, args.fq)

  end

end
