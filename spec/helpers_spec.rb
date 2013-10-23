require 'timecop'
require 'spec_helper'
require 'lims-core/helpers'

module Lims::Core
  describe Helpers do
    context "when dumping date" do
      before do
        Timecop.freeze(Time.now.utc)
      end

      let(:current_time) { Time.now.utc }
      let(:ruby_hash) { {:a => {:b => {:date => current_time}}} }
      let(:expected_json) { "{\"a\":{\"b\":{\"date\":\"#{current_time}\"}}}" }

      it "encodes correctly the hash into json" do
        Helpers::to_json(ruby_hash).should == expected_json
      end
    end
  end
end
