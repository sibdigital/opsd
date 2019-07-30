# created by knm
class PopUpAlertsController < ApplicationController
  helper :sort
  include SortHelper
  include PaginationHelper
  include ::IconsHelper
  include ::ColorsHelper
  def index
    sort_columns = {'id' => "#{Alert.table_name}.id",
                    'entity_type'=>"#{Alert.table_name}.entity_type",
                    'alert_date'=>"#{Alert.table_name}.alert_date",
                    'created_by'=>"#{Alert.table_name}.created_by",
                    'about'=>"#{Alert.table_name}.about",
                    'readed'=>"#{Alert.table_name}.readed"
    }
    sort_init 'id', 'desc'
    sort_update sort_columns
    @alerts = Alert.where(alert_type: 'PopUp').order(sort_clause).page(page_param).per_page(per_page_param)
  end
end
