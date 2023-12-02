class VersionsController < ApplicationController
  def show
    version = Version.find params[:id]
    game = version.game

    # Don't use serializer because we want to add in some stuff
    json = {
      id: version.id,
      number: version.number,
      size: version.size,
      command: game.command,
      environment: game.environment,
      number: version.number,
      storage_url: version.storage_url,
      content: version.content,
    }

    render json: json
  end
end
