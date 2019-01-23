namespace :copy do

  desc 'Copy EAD PDF files to public/files'
  task :pdf do
    target_dir = "#{app_root}/public/files/"
    pdf_dir = "#{app_root}/spec/fixtures/sample_pdf_files"

    unless File.directory?(target_dir)
       mkdir target_dir
    end
    puts "Copying files..."
    cp_r Dir.glob("#{pdf_dir}/*.pdf"), target_dir    
  end
end

def app_root
  Rails.root.to_s
end