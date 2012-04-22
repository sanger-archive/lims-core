# Spec requirements
require 'persistence/logger/spec_helper'

# Model requirements
require 'logger'
require 'lims/core/persistence/logger/store'

module Lims::Core::Persistence
  P = self
  module Logger
    class Array < P::Persistor
      include Persistor
    end
  end
  describe Logger::Store do
    def self.initialized_with_a_logger(method)
      context "initialized with a logger" do
        let (:logger) { ::Logger.new($stdout) }
        subject { described_class.new(logger, method) }
        it "should log objects to stdout" do
          logger.should_receive(:send).with(method, '["A1", "A2", "B1", "B2"]')
          subject.with_session do |session|
            session << %w(A1 A2 B1 B2)
          end
        end
      end
    end
    def self.initialized_with_an_IO(io)
    context "initialized to stdout" do
      subject { described_class.new(io) }
      it "should log objects to stdout" do
        io.should_receive(:write)
        subject.with_session do |session|
          session << %w(A1 A2 B1 B2)
        end
      end
    end
    end
    initialized_with_an_IO(STDOUT)
    initialized_with_an_IO(STDERR)

    initialized_with_a_logger(:info)
    initialized_with_a_logger(:warn)
  end
end
