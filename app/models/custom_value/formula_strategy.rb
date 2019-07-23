

class CustomValue::FormulaStrategy < CustomValue::FormatStrategy

  def typed_value
    unless value.blank?
      value.to_s
    end
  end

  def formatted_value

  end

  def validate_type_of_value

  end

end
