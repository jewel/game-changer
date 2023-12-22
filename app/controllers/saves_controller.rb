class SavesController < ApplicationController
  def latest
    user = User.find params[:user_id]
    game = Game.find params[:game_id]
    save = Save.joins(:version).where(user: user, version: {game: game})
      .order(:created_at).last

    if save
      bucket = Bucket.from_compact_json save.bucket
      save = save.as_json
      save[:bucket] = bucket.as_json
    end

    render json: save
  end

  def create
    user = User.find params[:user_id]
    version = Version.find params[:version_id]

    json = JSON.parse request.body.read, symbolize_names: true
    bucket = Bucket.from_json json

    save = Save.create!({
      user: user,
      version: version,
      station_id: 0,
      bucket: bucket.as_compact_json,
    })

    render plain: "OK"
  end
end
