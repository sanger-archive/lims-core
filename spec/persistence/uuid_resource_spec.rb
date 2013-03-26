# vi: ts=2:sts=2:et:sw=2 spell:spelllang=en
require 'persistence/spec_helper'

require 'lims-core/persistence/uuid_resource'

module Lims::Core
  module Persistence
    describe UuidResource do
      context "#class" do
        subject { UuidResource }
        it "validates valid uuid" do
          subject.valid?("12345678-abcd-1234-ABCD-1234567890ab").should be_true
        end

        it "invalidates unvaild uuid" do
          subject.valid?("12345678-Zbcd-1234-ABCD-1234567890ab").should be_false
          subject.valid?("12345678-Zbcd-1234-ABCD-1234567890").should be_false
          subject.valid?("I am not a uuid").should be_false
        end

        it "generates a UUID" do
          subject.valid?(subject.generate_uuid()).should be_true
        end 

        it "generates different UUID" do
          u1,u2 = 2.times { subject.generate_uuid()}
          u1.should_not == u2
        end

        context "#conversion" do
          context "to packed string" do
            let(:to_pack) { "41424344-4546-4748-6162-636465666768" }
            let(:packed) { "ABCDEFGHabcdefgh" }

            it "pack" do
              subject.pack(to_pack).should == packed
            end

            it "unpack" do
              subject.unpack(packed).should == to_pack
            end
            it "converts unpacked to valid string" do
              subject.valid?(subject.unpack(packed))
            end
          end
          context "to bignum" do
            let(:bignum) { 0x12345678abcd1234abcd1234567890ab }
            let(:string) { "12345678-abcd-1234-abcd-1234567890ab" }

            it "converts string to bignum" do
              subject.string_to_bignum(string).should == bignum
            end

            it "converts bignum to string" do
              subject.bignum_to_string(bignum).should == string
            end
            it "converts bignum to valid string" do
              subject.valid?(subject.bignum_to_string(bignum))
            end
          end
        end
      end


      context "created without an uuid" do
        subject { described_class.new(:modeli => "model", :key => 1) }
        it "should create an new uuid" do
          subject.uuid.should_not be_nil
        end
      end
      context "created with an uuid" do
        let(:uuid) { UuidResource.generate_uuid }
        subject { described_class.new(:model => "model", :key => 1, :uuid => uuid) }
        it "keeps the same uuid" do
          subject.uuid.should == uuid
        end
      end
    end
  end
end
