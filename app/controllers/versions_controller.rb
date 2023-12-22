class VersionsController < ApplicationController
  def show
    version = Version.find params[:id]
    game = version.game

    files = Bucket.from_compact_json(version.bucket).as_json

    # Don't use serializer because we want to add in some stuff
    json = {
      id: version.id,
      number: version.number,
      size: version.size,
      command: game.command,
      environment: game.environment,
      number: version.number,
      bucket: files,
    }

    render json: json
  end
end
