# Spec requirements
require 'persistence/sequel/spec_helper'

# Model requirements
require 'lims-core/persistence/sequel/store'
require 'lims-core/persistence/sequel/session'


module Lims::Core::Persistence
  module Sequel
    describe Session, :session => true, :persistence => true, :sequel => true do
      context "with sqlite underlying" do
        let(:db) { ::Sequel.sqlite('') }
        let(:store) { Store.new(db) }

        context "#transaction" do
          let(:a) { "A" }
          let(:b) { "B" }
          let(:c) { "C" }

          before() do
              db.create_table :names do
                primary_key :id
                String :name
              end

              Session.any_instance.stub(:save) do |arg|
                case arg
                when "A", "B"
                  db[:names].insert(:name => arg)
                when "C"
                  raise RuntimeError, "Can't save 'C'"
                end
              end
          end

          it "save the 2 if no problem" do
            expect { store.with_session do |s|
              s << a << b
            end }.to change{db[:names].count}.by(2)
          end

          it "saves 0 if the second doesn't save" do
            expect {
              begin
              store.with_session do |s|
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
