class Admin::SiteCustomization::TextsController < Admin::SiteCustomization::BaseController
  before_action :change_language, only: [:index]

  def index
    @files = locale_files
  end

  def edit
    (file = find_locale_file(params[:id])) || raise(ActionController::RoutingError, "Not Found")
    file = YAML.load_file(file[:path])

    @translations = flatten_hash(file)
  end

  private

    def change_language
      if params[:language].present?
        session[:customization_language] = params[:language]
        flash[:notice] = "Changed language"
      end
    end

    def locale_directory
      language = (session[:customization_language] || "en")
      Rails.root.join("config", "locales", language)
    end

    def locale_files
      filenames = Dir.entries(locale_directory).select { |object| object.end_with? ".yml" }

      filenames.map do |filename|
        {
          id: filename.chomp(".yml"),
          name: filename.chomp(".yml").titleize,
          filename: filename,
          path: "#{locale_directory}/#{filename}"
        }
      end
    end

    def find_locale_file(id)
      locale_files.find { |file| file[:id] === id }
    end

    def flatten_hash(param, prefix = nil)
      param.each_pair.reduce({}) do |a, (k, v)|
        v.is_a?(Hash) ? a.merge(flatten_hash(v, "#{prefix}#{k}.")) : a.merge("#{prefix}#{k}".to_sym => v)
      end
    end
end
