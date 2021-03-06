Trestle.resource(:videos) do
  # menu do
    # item :videos
    # item :videos, group: :admin
  # end
  scope :all, -> { Video.order(:uploaded_at => :desc) }, default: true

  search do |query|
    if query
      query = query.titleize
      Video.search_for("#{query}")
    else
      Video.order(:uploaded_at => :desc)
    end
  end

  to_param do |instance|
    if instance.slug.present?
      instance.slug
    else
      instance.id
    end
  end

  find_instance do |params|
    Video.friendly.find(params[:id])
  end

  controller do
    include ActionView::Helpers::AssetUrlHelper
    def show
      self.instance = admin.find_instance(params)
      # commontator_thread_show(video)
      self.instance.full_url = File.join(Rails.application.routes.url_helpers.root_url,admin.instance_path(instance))
      imgurl = instance.thumbnail_url
      # set_meta_tags og: {
      #   title: "#{instance.title} | Openpilot Community",
      #   image: instance.thumbnail_url,
      #   type: "website",
      #   description: instance.description
      # }
      # set_meta_tags keywords: [instance.title.split(' '),['openpilot','vehicle','support','master','list','of','vehicles','supported','compatible','compatibility']].flatten
      # set_meta_tags description: instance.description
      set_meta_tags(
        og: {
          title: instance.title,
          image: imgurl,
          site_name: "Openpilot Community",
          url: @video_url,
          type: "video",
          author: instance.author
        },
        robots: "index, follow",
        "article:published_time": instance.uploaded_at.iso8601(9),
        "article:publisher": "https://opc.ai/",
        "article:author": instance.author,
        keywords: ['openpilot','vehicle','support',instance.title.split,'of','vehicles','supported','compatible','compatibility'].flatten,
        description: "Watch #{instance.title} and comment. #{instance.description}",
        canonical: @video_url,
        image_src: imgurl,
        author: instance.author,
        twitter: {
          creator: "@#{instance.author}",
          title: instance.title,
          card: "summary-large",
          author: instance.author
        }
      )
      super
    end
  end
  table do
    column :title, header: "" do |instance|
      render "row", instance: instance
    end
  end

  # Customize the form fields shown on the new/edit views.
  #
  form do |video|
    tab :general do
      if video.persisted?
        static_field :title, video.title
        select :hardware_item_ids, HardwareItem.all, { label: "Tag hardware in this video" }, { multiple: true }
        select :vehicle_config_ids, VehicleConfig.all, { label: "Tag vehicles in this video" }, { multiple: true }
        static_field :provider_name, video.provider_name
        static_field :author, video.author
        static_field :author_url, video.author_url
        static_field :thumbnail_url, video.thumbnail_url
        static_field :description, video.description
        static_field :uploaded_at, video.uploaded_at
      else
        text_field :video_url
      end
    end

    sidebar do
      static_field :html, label: "Preview", class: "video-output" do
        content_tag(:div, video.persisted? ? video.html.html_safe : nil, class: "video-output")
      end
      
      static_field :html, label: "Vehicle(s)" do
        content_tag(:ul) do
          video.vehicle_configs.map do |config|
            content_tag(:li) do
              config.name
            end.html_safe
          end.join('').html_safe
        end
      end
      # collection_select :parent_id, VehicleConfig.where.not(id: vehicle_config.id).includes(:vehicle_make,:vehicle_model).where(:vehicle_make => vehicle_config.vehicle_make.blank? ? nil : vehicle_config.vehicle_make,:vehicle_model => vehicle_config.vehicle_model.blank? ? nil : vehicle_config.vehicle_model).where("parent_id IS NULL").order("vehicle_models.name, year"), :id, :name, include_blank: true, label: "Associate to new parent"
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
  #   params.require(:video).permit(:name, ...)
  # end
end
