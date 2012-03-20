# Spec requirements
require 'persistance/sequel/spec_helper'

# Model requirements
require 'lims/core/persistance/sequel/store'
require 'lims/core/persistance/sequel/session'


module Lims::Core::Persistance
  module Sequel
    describe Session do
      context "with sqlite underlying" do
        let(:store) { PS::Store.new(::Sequel.sqlite('')) }
      end
    end
  end
end
