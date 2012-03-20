# Spec requirements
require 'persistance/sequel/spec_helper'

# Model requirements
require 'lims/core/persistance/sequel/store'

module Lims::Core::Persistance
    describe Sequel::Store do
      context "initialized with a valid database" do
        let(:db) { ::Sequel.sqlite('') }
        it "must  be valid" do
          expect { described_class.new(db) }.to_not raise_error
        end
      end

      context "initialized with something elese" do
        it "must  be invalid" do
          expect { described_class.new("my database") }.to raise_error
        end
      end
    end
end
