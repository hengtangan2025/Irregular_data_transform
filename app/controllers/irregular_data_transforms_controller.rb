class IrregularDataTransformsController < ApplicationController
  def index
    
  end


  def transfer_page
    @show_transfer_result = `#{params[:shell_command]}`
  end

  def transfer_action
    require 'fileutils'
    will_transfer_file = params[:transfer_file]
    will_transfer_file_path = File.join("public",will_transfer_file.original_filename)
    FileUtils.cp will_transfer_file.path, will_transfer_file_path
    redirect_to :action => "transfer_page", :shell_command => "./public/graphml2hintpipe.pl ./public/#{will_transfer_file.original_filename}"
  end

  def graphviz 
  end

end