module Members
  class BusynessFormCell < ::RailsCell
    include RemovedJsHelpersHelper

    options :row, :params, :busyness

    def member
      model
    end

    def form_url
      url_for form_url_hash
    end

    def form_url_hash
      {
        controller: '/members',
        action: 'update',
        id: member.id,
        page: params[:page],
        per_page: params[:per_page]
      }
    end

    def busyness_box(busyness)
      number_field_tag 'busyness',
                       busyness,
                       min: 0,
                       max: 100
    end

  end
end

