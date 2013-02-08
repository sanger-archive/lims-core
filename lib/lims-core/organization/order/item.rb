# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en 
require 'common'
require 'lims/core/resource'
require 'lims-core/organization/user'
require 'lims-core/organization/study'

require 'state_machine'

StateMachine::Machine.ignore_method_conflicts = true
module Lims::Core
  module Organization
    class Order
      # @see Order
      # An item has an iteration attribute, representing the number of times
      # its been started. Iteration > 1 means that the items has been failed at least once.
      # Iteration = 0 means that the item has been set directly as source and is part of the
      # initial order.
      # The status represents the *progress* of the item.
      class Item
        include Resource

        attribute :iteration, Fixnum, :writer => :private, :default => 0
        attribute :uuid, String
        attribute :status, State

        def initialize(*args)
          super(*args)
          iteration
        end

        def iterate
          @iteration+=1
        end
        state_machine :status, :initial  => :pending do
          # This is the initial state. The item hasn't either been set as a source
          # or started. It can appear in the *inbox*.

          after_transition  :on => :start, :do => :iterate

          state :pending do
          end

          # the item creation process has been started.
          state :in_progress do
          end

          # The item exists and is available for the next step of the order.
          state :done do
            def uuid=(uuid)
              raise NoMethodError
            end
          end

          # The item has been used to create the next step of the order.
          # It's not going to be used anymore in the order.
          state :unused do
            def uuid=(uuid)
              raise NoMethodError
            end
          end

          # The item creation has failed. It can be reset to pending
          # and then restarted
          state :failed do
          end

          # The item has been cancelled by a user decision and can't be done.
          state :cancelled do
          end

          event :start do
            transition [:pending, :failed] => :in_progress
          end

          event :complete do
            transition [:pending, :in_progress] => :done
          end

          event :unuse do
            transition [:done] => :unused
          end

          event :cancel do
            transition [:pending, :in_progress, :failed] => :cancelled
          end

          event :fail do
            # Transition from pending allowed to be able to 'create' failed item
            transition [:pending, :in_progress]=> :failed
          end

          event :reset do
            transition [:failed, :in_progress] => :pending
          end
          end
        end
      end
    end
  end

