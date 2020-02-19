UpdateUserPopupSettingsService = Struct.new(:user) do
  def call(popups_delay: nil,
           disable_popups: nil)

    set_popups_delay(popups_delay)
    set_disable_popups(disable_popups)

    ret_value = false

    user.transaction do
      if (ret_value = user.pref.save)
      end
    end
    ret_value
  end

  private

  def set_popups_delay(popups_delay)
    user.pref.popups_delay = popups_delay unless popups_delay.nil?
  end

  def set_disable_popups(disable_popups)
    user.pref.disable_popups = !disable_popups.nil?
  end
end

