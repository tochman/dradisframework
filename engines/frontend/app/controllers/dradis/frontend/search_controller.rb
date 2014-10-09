module Dradis
  module Frontend
    class SearchController < Dradis::Frontend::AuthenticatedController
      def search
        keyword = params[:q]
        models = find_models(keyword)

        models.each do |model|
          #results = ObjectSpace.const_get("Dradis::Core::#{model}").search(keyword)
           #debugger
          results = ("Dradis::Core::#{model}".classify.constantize).search(keyword)
          self.instance_variable_set("@#{model.downcase.pluralize}", results)
        end
        render layout: 'dradis/themes/snowcrash'
      end

      private

      def find_models(keyword)
        #debugger
        models = keyword.scan(/is:([a-zA-Z]+)/).flatten.map { |model| model.singularize.capitalize }
        available_searches = ["Issue", "Note", "Evidence"]

        if models.empty?
          available_searches
        else
          available_searches & models
        end
      end
    end
  end
end
