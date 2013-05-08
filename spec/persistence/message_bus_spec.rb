require 'lims-core/persistence/message_bus'

module Lims::Core
  module Persistence
    describe MessageBus, :message_bus => true do
      context "to be valid" do
        let(:url) { "amqp://user:password@localhost:55672" }
        let(:exchange_name) { "exchange_name" }
        let(:durable) { true }
        let(:prefetch_number) { 30 }
        let(:heart_beat) { 0 }
        let(:bus_settings) { {"url" => url, "exchange_name" => exchange_name, "durable" => durable, "prefetch_number" => prefetch_number, "heart_beat" => heart_beat } }

        it "requires a RabbitMQ host" do
          described_class.new(bus_settings - ["url"]).valid?.should == false
        end

        it "requires an exchange name" do
          described_class.new(bus_settings - ["exchange_name"]).valid?.should == false
        end

        it "requires the durable option" do
          described_class.new(bus_settings - ["durable"]).valid?.should == false
        end

        it "requires a prefetch number" do
          described_class.new(bus_settings - ["prefetch_number"]).valid?.should == false
        end

        it "not requires a heart_beat value" do
          described_class.new(bus_settings - ["heart_beat"]).valid?.should == true
        end

        it "requires correct settings" do
          described_class.new(bus_settings).valid?.should == true
        end

        it "requires correct settings to connect to the message bus" do
          expect do
            described_class.new(bus_settings - ["url"]).connect
          end.to raise_error(MessageBus::InvalidSettingsError)
        end

        it "requires an exchange to publish a message" do
          expect do
            described_class.new(bus_settings).publish("message")
          end.to raise_error(MessageBus::ConnectionError)
        end
      end
    end
  end 
end

