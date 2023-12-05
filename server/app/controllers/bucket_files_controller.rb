class BucketFilesController < ApplicationController
  def create
    hash = BucketFile.store params[:file]
    render json: { hash: hash }
  end
end
