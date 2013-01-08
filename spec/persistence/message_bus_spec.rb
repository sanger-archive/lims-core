require 'lims-core/persistence/message_bus'

module Lims::Core
  module Persistence
    describe MessageBus do
      context "to be valid" do
        let(:host) { "host" }
        let(:port) { 5672 }
        let(:exchange_name) { "exchange_name" }
        let(:durable) { true }
        let(:prefetch_number) { 30 }
        let(:bus_settings) { {"host" => host, "port" => port, "exchange_name" => exchange_name, "durable" => durable, "prefetch_number" => prefetch_number} }

        it "requires a RabbitMQ host" do
          described_class.new(bus_settings - ["host"]).valid?.should == false
        end

        it "requires a port" do
          described_class.new(bus_settings - ["port"]).valid?.should == false
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

        it "requires correct settings" do
          described_class.new(bus_settings).valid?.should == true
        end
      end
    end
  end 
end

