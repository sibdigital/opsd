# created by knm
class PopUpAlertsController < ApplicationController
  def get_alerts
    @alerts=Alert.where(alert_type: 'PopUp')
    if Alert.where(alert_type: 'PopUp').count.positive?
      # render plain: Alert.where(alert_type: 'PopUp').count
      render json: @alerts.select([:id, :entity_id, :entity_type, :alert_date])
    end
    # render plain: "OK"
  end
end
