# Spec requirements
require 'persistence/spec_helper'

# Model requirements
require 'lims-core/persistence/store'
require 'lims-core/persistence/session'


module Lims::Core::Persistence
  module Sequel
    describe Session, :session => true, :persistence => true, :persistence => true do
      let(:store) { Store.new() }

      context "#transaction" do
        let(:a) { "A" }
        let(:b) { "B" }
        let(:c) { "C" }

        it "save the 2 if no problem" do
          store.with_session do |session|
            session.should_receive(:save).with(a)
            session.should_receive(:save).with(b)
            session << a << b
          end
        end

        context "#dirty attribute strategy" do
          context "no strategy" do
            it "save read object" do
              store.with_session do |session|
                session.should_not_receive(:save).with(a)
                session.should_receive(:save).with(b)
                session << a << b
              end
            end
          end
        end
      end
    end
  end
end
