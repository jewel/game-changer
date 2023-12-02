Trestle.resource(:users) do
  menu do
    item :users, icon: "fa fa-user"
  end

  table do
    column :name
    actions
  end

  form do |user|
    tab :info do
      text_field :name
      password_field :password
      static_field :icon do
        content_tag(
          :img,
          nil,
          src: "data:;base64,#{user.icon}",
          width: "100",
        )
      end if user.icon
      file_field :icon, label: "New Icon"
    end
  end
end
