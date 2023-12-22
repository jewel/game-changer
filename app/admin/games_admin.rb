Trestle.resource(:games) do
  menu do
    item :games, icon: "fa fa-gamepad"
  end

  # Customize the table columns shown on the index view.
  table do
    column :name
    column :size do
      number_to_human_size _1.default_version&.size
    end
    actions
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |game|
    tab :info do
      text_field :name
      static_field :icon do
        content_tag(
          :img,
          nil,
          src: Bucket.url(game.icon),
          width: "100",
        )
      end if game.icon
      file_field :icon, label: "New Icon"
      if !game.persisted?
        text_field :version_number
        file_field :upload_tar
      end
      text_field :command
      text_area :environment
    end

    if game.persisted?
      tab :versions do
        table game.versions.order(created_at: :desc), admin: :versions do
          column :number
          column :size do
            number_to_human_size _1.size
          end
          column :created_at
          actions
        end

        concat admin_link_to "Add New", admin: :versions, action: :new, params: { game_id: game.id }, class: "btn btn-success"
      end
    end
  end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:game).permit(:name, ...)
  # end
end
