Trestle.resource(:vehicle_config_statuses) do
  # menu do
  #   item :vehicle_config_statuses, icon: "fa fa-star", group: :admin, label: "Support Statuses"
  # end

  # Customize the table columns shown on the index view.
  #
  table do
    column :name
    # column :created_at, align: :center
    # actions
  end

  # Customize the form fields shown on the new/edit views.
  #
  # form do |vehicle_config_status|
  #   text_field :name
  #
  #   row do
  #     col(xs: 6) { datetime_field :updated_at }
  #     col(xs: 6) { datetime_field :created_at }
  #   end
  # end

  # By default, all parameters passed to the update and create actions will be
  # permitted. If you do not have full trust in your users, you should explicitly
  # define the list of permitted parameters.
  #
  # For further information, see the Rails documentation on Strong Parameters:
  #   http://guides.rubyonrails.org/action_controller_overview.html#strong-parameters
  #
  # params do |params|
  #   params.require(:vehicle_config_status).permit(:name, ...)
  # end
end
