Trestle.resource(:versions) do
  build_instance do |attrs, params|
    scope = params[:game_id] ? Game.find(params[:game_id]).versions : Version
    scope.new attrs
  end

  form do |version|
    if version.game
      hidden_field :game_id
      static_field :game, version.game.name
    end

    text_field :number

    if version.persisted?
      static_field :size, number_to_human_size(version.size)
    else
      file_field :directory, multiple: true, webkitDirectory: true
      file_field :tar
    end
  end
end
