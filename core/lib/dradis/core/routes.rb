module Dradis
  module Core

    # This extensions to the Core engine allow other engines to append new
    # routes to the application.
    #
    # Code borrowed from:
    #   https://github.com/spree/spree/blob/0d34190fd47e9520174118855941ecc207b8a801/core/lib/spree/core/routes.rb
    class Engine < ::Rails::Engine
      def self.add_routes(&block)
        @dradis_routes ||= []

        # Anything that causes the application's routes to be reloaded,
        # will cause this method to be called more than once
        # i.e. https://github.com/plataformatec/devise/blob/31971e69e6a1bcf6c7f01eaaa44f227c4af5d4d2/lib/devise/rails.rb#L14
        # In the case of Devise, this *only* happens in the production env
        # This coupled with Rails 4's insistence that routes are not drawn twice,
        # poses quite a serious problem.
        #
        # This is mainly why this whole file exists in the first place.
        #
        # Thus we need to make sure that the routes aren't drawn twice.
        unless @dradis_routes.include?(block)
          @dradis_routes << block
        end
      end

      def self.append_routes(&block)
        @append_routes ||= []
        # See comment in add_routes.
        unless @append_routes.include?(block)
          @append_routes << block
        end
      end

      def self.draw_routes(&block)
        @dradis_routes ||= []
        @append_routes ||= []
        eval_block(block) if block_given?
        @dradis_routes.each { |r| eval_block(&r) }
        @append_routes.each { |r| eval_block(&r) }
        # # Clear out routes so that they aren't drawn twice.
        @dradis_routes = []
        @dradis_routes = []
      end

      private

        def eval_block(&block)
          Dradis::Core::Engine.routes.eval_block(block)
        end
    end
  end
end