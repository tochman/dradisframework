module Dradis
  module Frontend
    class SearchController < Dradis::Frontend::AuthenticatedController
      layout 'dradis/themes/snowcrash'

      def search
        keyword = params[:q]
        return if keyword.blank?
        models = find_models(keyword)
        keyword = filter_keyword(keyword)

        @results = models.map do |model|
          m = ("Dradis::Core::#{model}".classify.constantize)
          m.search(keyword).paginate(page: params[:page])
        end
        @type = params[:type].singularize.capitalize if params[:type].present?
      end

      private

      def find_models(keyword)
        models = keyword.scan(/is:([a-zA-Z]+)/).flatten.map { |model| model.singularize.capitalize }

        available_searches = %w(Issue Note Evidence)

        if models.empty?
          available_searches
        else
          available_searches & models
        end
      end

      def filter_keyword(keyword)
        keyword.gsub(/is:([a-zA-Z]+)/, '').strip
      end
    end
  end
end
