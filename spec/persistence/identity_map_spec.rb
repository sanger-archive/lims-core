# Spec requirements
require 'persistence/spec_helper'

# Model requirements
require 'lims-core/persistence/identity_map'




module Lims::Core::Persistence
  class IdentityMapClass
    include IdentityMap
  end

  describe IdentityMapClass, :identity_map => true, :persistence => true do

    context "with a object mapped to an id" do
      let(:id) { 1 }
      let(:object) { "Object 1" }
      before {subject.map_id_object(id,object) }

      it "must find the object by id" do
        subject.object_for(id).should == object
      end

      it "must find the id by object" do
        subject.id_for(object).should == id
      end

      it "must fail when mapping another object with the same id" do
        expect { subject.map_id_object(id, "Object #2") }.to raise_error(IdentityMap::DuplicateIdError)
      end

      it "must fail when mapping another id with the same object" do
        expect { subject.map_id_object(2, object) }.to raise_error(IdentityMap::DuplicateObjectError)
      end

      it "must not fail when mapping it again" do
        expect { subject.map_id_object(id, object) }.not_to raise_error(IdentityMap::DuplicateError)
      end

      it "must yield the object" do
        subject.object_for(id) do |o|
          o.should == object
        end
      end

      it "must not yield if the object can't be found" do
        subject.object_for("wrong id") do |o|
          raise "not found"
        end.should be_nil
      end
    end
  end
end
