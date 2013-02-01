# Spec requirements
require 'persistence/logger/spec_helper'
require 'laboratory/plate_and_gel_shared'

# Model requirements
require 'lims/core/persistence/logger/store'

module Lims::Core::Persistence
  describe Logger::Store do
    include_context "plate or gel factory"
    context "initialized with a logger" do
      let(:number_of_rows) { 1 }
      let(:number_of_columns) { 2 }
      let (:logger) { ::Logger.new($stdout) }
      let(:plate) { new_plate_or_gel_with_samples(Lims::Core::Laboratory::Plate, 2) }
      subject { described_class.new(logger) }
      it "should log plate to stdout" do
        logger.should_receive(:send).with(:info, 'Lims::Core::Laboratory::Plate: {:number_of_rows=>1, :number_of_columns=>2}')
        logger.should_receive(:send).with(:info, '- [0] - Lims::Core::Laboratory::Aliquot: {:sample=>"Sample A1/1", :tag=>nil, :quantity=>nil, :type=>nil}')
        logger.should_receive(:send).with(:info, '- [0] - Lims::Core::Laboratory::Aliquot: {:sample=>"Sample A1/2", :tag=>nil, :quantity=>nil, :type=>nil}')
        logger.should_receive(:send).with(:info, '- [1] - Lims::Core::Laboratory::Aliquot: {:sample=>"Sample A2/1", :tag=>nil, :quantity=>nil, :type=>nil}')
        logger.should_receive(:send).with(:info, '- [1] - Lims::Core::Laboratory::Aliquot: {:sample=>"Sample A2/2", :tag=>nil, :quantity=>nil, :type=>nil}')
        subject.with_session do |session|
          session << plate
        end
      end
    end
  end
end
