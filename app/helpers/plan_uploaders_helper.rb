module PlanUploadersHelper

  RUSSIAN_MONTH_NAMES_SUBSTITUTION = {
    'январь' => 'jan', 'февраль' => 'feb', 'март' => 'mar',
    'апрель' => 'apr', 'май' => 'may', 'июнь' => 'jun',
    'июль' => 'jul', 'август' => 'aug', 'сентябрь' => 'sep',
    'октябрь' => 'oct', 'ноябрь' => 'nov', 'декабрь' => 'dec'
  }.freeze

  def russian_to_english_date(date_string)
    date_string.downcase.gsub(/январь|февраль|март|апрель|май|июнь|июль|август|сентябрь|октябрь|ноябрь|декабрь/, RUSSIAN_MONTH_NAMES_SUBSTITUTION)
  end

  # ***********************************************

  def create_russian_map
    self.english.inject({}) do |acc, tuple|
      rus_up, rus_low = tuple.last
      eng_value       = tuple.first
      acc[rus_up]  ? acc[rus_up]  << eng_value.capitalize : acc[rus_up]  = [eng_value.capitalize]
      acc[rus_low] ? acc[rus_low] << eng_value            : acc[rus_low] = [eng_value]
      acc
    end
  end

  def detect_input_language(text)
    text.scan(/\w+/).empty? ? :russian : :english
  end

  def enforce_input_language(language)
    if language == :english
      :russian
    else
      :english
    end
  end

  def english
    { "a"=>["А","а"], "b"=>["Б","б"], "v"=>["В","в"], "g"=>["Г","г"], "d"=>["Д","д"], "e"=>["Е","е"], "yo"=>["Ё","ё"], "zh"=>["Ж","ж"],
      "z"=>["З","з"], "i"=>["И","и"], "j"=>["Й","й"], "k"=>["К","к"], "l"=>["Л","л"], "m"=>["М","м"], "n"=>["Н","н"], "o"=>["О","о"], "p"=>["П","п"], "r"=>["Р","р"],
      "s"=>["С","с"], "t"=>["Т","т"], "u"=>["У","у"], "f"=>["Ф","ф"], "h"=>["Х","х"], "x"=>["Кс","кс"], "c"=>["Ц","ц"], "ch"=>["Ч","ч"], "sh"=>["Ш","ш"],
      "sch"=>["Щ","щ"], "y"=>["Ы","ы"], ""=>["Ь","ь"], "eh"=>["Э","э"], "yu"=>["Ю","ю"], "ya"=>["Я","я"] }
  end

  def russian
    @russian ||= create_russian_map
  end

  def convert!(text, enforce_language = nil)
    language = if enforce_language
                 #enforce_input_language(enforce_language)
                 if enforce_language == :english
                   :russian
                 else
                   :english
                 end
               else
                 #self.detect_input_language(text.split(/\s+/).first)
                 text.scan(/\w+/).empty? ? :russian : :english
               end

    map = self.send(language.to_s).sort_by {|k,v| v.length <=>  k.length}
    map.each do |translit_key, translit_value|
      text.gsub!(translit_key.capitalize, translit_value.first)
      text.gsub!(translit_key, translit_value.last)
    end
    text
  end

  def convert(text, enforce_language = nil)
    convert!(text.dup, enforce_language)
  end

end
