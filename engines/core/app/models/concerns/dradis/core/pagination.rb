module Dradis
  module Core
    module Pagination
      def self.included(base)
        base.extend(ClassMethods)
        base.class_eval do
        end
      end

      module ClassMethods
        PER_PAGE = 15

        def paginate(options)
          options = options.dup
          pagenum = options.fetch(:page, 1)
          per_page = (options.delete(:per_page) || PER_PAGE).to_i

          limit(per_page).offset((pagenum.to_i - 1) * per_page)
        end

        def page
          rel.offset_value.to_i/rel.limit_value.to_i + 1
        end

        def first_page?
          page == 1
        end

        def last_page?
          paginate(page: page + 1).empty?
        end

        private

        def rel
          if ::ActiveRecord::Relation === self
            self
          elsif !defined?(::ActiveRecord::Scoping) or ::ActiveRecord::Scoping::ClassMethods.method_defined? :with_scope
            # Active Record 3
            scoped
          else
            # Active Record 4
            all
          end
        end
      end
    end
  end
end
