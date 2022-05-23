namespace :solr_tools do

  desc 'Fix screwy dates'
  task :reindex, [:q, :rows, :fq] do |t, args|
    require 'import/solr_tools'
    SolrTools.reindex(args.q, args.rows, args.fq)

  end

  task :update, [:q, :rows, :update, :with] do |t, args|
    require 'import/solr_tools'
    SolrTools.update(args.q, args.rows, args.update, args.with)

  end

end
