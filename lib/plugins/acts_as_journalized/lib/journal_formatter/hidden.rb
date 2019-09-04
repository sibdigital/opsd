class JournalFormatter::Hidden< JournalFormatter::Attribute
  def render_ternary_detail_text(label, value, old_value, options)
    I18n.t(:text_journal_hidden, label: label)
  end
end
