# Spec requirements
require 'persistence/sequel/spec_helper'

# Model requirements
require 'lims-core/persistence/sequel/store'
require 'lims-core/persistence/sequel/session'
require 'lims-core/persistence/sequel/persistor'


module Lims::Core::Persistence
  module Sequel
    describe Session, :session => true, :persistence => true, :persistence => true, :sequel => true do
      context "with sqlite underlying" do
        include_context "sqlite db"
        include_context "with test store"

        context "#transaction" do
          let(:a) { ForTest::Name.new(:name => "A") }
          let(:b) { ForTest::Name.new(:name => "B") }
          let(:c) { ForTest::Name.new(:name => "C") }

          before {
            c.stub(:attributes) do
              raise RuntimeError, "Can't save '#{inspect}'"
            end
          }

          it "save the 2 if no problem" do
            expect { store.with_session do |s|
                s << a << b
              end }.to change{db[:names].count}.by(2)
          end

          it "saves 0 if the second doesn't save" do
            expect {
              begin
                store.with_session do |s|

                  module Lims::Core::Peristence
                  end
                  s << a << c
                end
              rescue
              end
            }.to change{db[:names].count}.by(0)
          end

          xit "saves 0 if the second is not valid" do
          end
        end
      end
    end
  end
end
