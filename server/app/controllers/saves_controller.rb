class SavesController < ApplicationController
  def latest
    user = User.find params[:user_id]
    game = Game.find params[:game_id]
    save = Save.joins(:version).where(user: user, version: {game: game})
      .order(:created_at).last

    render json: save
  end

  def upload
    user = User.find params[:user_id]
    version = Version.find params[:version_id]

    save = Save.create!({
      user: user,
      version: version,
      size: request.body.size,
      station_id: 0,
    })
    save.write_to_disk request.body

    render plain: "OK"
  end
end
