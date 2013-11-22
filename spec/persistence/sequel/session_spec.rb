# Spec requirements
require 'persistence/sequel/spec_helper'

# Model requirements
require 'lims-core/persistence/sequel/store'
require 'lims-core/persistence/sequel/session'
require 'lims-core/persistence/sequel/persistor'


module Lims::Core::Persistence
  module ForTest
    class Name
      include Lims::Core::Resource
      attribute :name, String
      class NamePersitor < Lims::Core::Persistence::Persistor
        Model = Name
      end
    end
  end

  module Sequel
    describe Session, :session => true, :persistence => true, :persistence => true, :sequel => true do
      context "with sqlite underlying" do
        let(:db) { ::Sequel.sqlite('') }
        let(:store) { Store.new(db).tap do 
            db.create_table :primary_keys do
              primary_key :id
              String :table_name
              Integer :current_key
            end
          end
        }

        context "#transaction" do
          let(:a) { ForTest::Name.new(:name => "A") }
          let(:b) { ForTest::Name.new(:name => "B") }
          let(:c) { ForTest::Name.new(:name => "C") }

          before() do
            db.create_table :names do
              primary_key :id
              String :name
            end

            c.stub(:attributes) do
              raise RuntimeError, "Can't save '#{inspect}'"
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
