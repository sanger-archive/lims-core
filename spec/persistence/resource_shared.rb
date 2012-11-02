shared_examples_for "storable resource" do |model_name, tables|
  context "created and added to session" do
    tables.each do |table_name, count| 
      it "modifies the #{table_name} table" do
        expect do
          store.with_session { |s| s << subject }
        end.to change { db[table_name].count }.by(count)
      end
    end
    it "should be reloadable" do
      resource_id = save(subject)
      store.with_session do |session|
        session.public_send(model_name)[resource_id].should == subject
      end
    end

    context "created but not added to a session" do
      tables.each do |table_name, count| 
        it "should not be saved" do
          expect do 
            store.with_session { |_| subject }
          end.to change{ db[tables].count }.by(0)
        end 
      end
    end
  end
end
