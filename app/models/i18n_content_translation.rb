class I18nContentTranslation < ApplicationRecord
  belongs_to :i18n_content

  def self.existing_languages
    self.select(:locale).distinct.map { |l| l.locale.to_sym }.to_a
  end
end
