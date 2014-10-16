module Dradis
  module Frontend
    module SearchHelper

      def to_sidebar(object)
        if object.present? && object.any?
          link_to search_path(q: params[:q], page: params[:page], type: model_name_from(object).singularize) do
            "<p><i class='icon-file-text'></i> In #{model_name_from(object)}: <span class='badge pull-right'>#{object.count}</span></p>".html_safe
          end
        end
      end

      def search_results(items)
        if items.present? && items.any?
          content_tag(:ul) do
            concat(content_tag(:h4, ("Found in #{model_name_from(items)}")))
            items.collect do |item|
              concat(content_tag(:h5, "Referenced to: #{link_to item.node.label, item.node}".html_safe))
              if item.class == Dradis::Core::Evidence
                concat(content_tag(:li, render_html(item.content), class: 'result'))
              else
                concat(content_tag(:li, render_html(item.text), class: 'result'))
              end
            end
          end
        end
      end

      def results_found?
        @results.flatten.any?
      end

      private

      # Not used right now. Dont think about the links for now
      def link(item)
        if item.class.name.constantize == Dradis::Core::Issue
          link_to item.text, url_for(item)
        else
          link_to item.text, url_for(['node', item])
        end
      end

      def render_html(string)
        RedCloth.new(string.gsub(/#\[([\w\s]+)?\]#[\r|\n]/){ "h5. #{$1}\n" }, [:filter_html]).to_html.html_safe
      end

      def model_name_from(arr)
        arr[0].class.name.demodulize.pluralize
      end
  end
  end
end
