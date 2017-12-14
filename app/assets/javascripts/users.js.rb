# # Place all the behaviors and hooks related to the matching controller here.
# # All this logic will automatically be available in application.js.
# # You can use Opal in this file: http://opalrb.org/
# #
# #
# # Here's an example view class for your controller:
# #
# class UsersView
#   # We should have <body class="controller-<%= controller_name %>"> in layouts
#   def initialize(selector = 'body.controller-users')
#     @selector = selector
#   end
#
#   def setup
#     on(:click, '#lar-check', &method(:check_lar))
#   end
#
#   def check_lar(event)
#     event.prevent
#     puts "Hello! (You just clicked on a link)"
#   end
#
#
#   private
#
#   attr_reader :selector, :element
#
#   # Uncomment the following method to look for elements in the scope of the
#   # base selector:
#   #
#   # def find(selector)
#   #   Element.find("#{@selector} #{selector}")
#   # end
#
#   # Register events on document to save memory and be friends to Turbolinks
#   def on(event, selector = nil, &block)
#     Element[`document`].on(event, selector, &block)
#   end
# end
#
# UsersView.new.setup
# puts "asdf"
