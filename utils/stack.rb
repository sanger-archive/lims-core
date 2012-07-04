    require 'sequel'
    require 'logger'

    DB=Sequel.sqlite '', :loggers => [Logger.new($stdout)]
    # Create test table
    DB.create_table :uuids do
      primary_key :id
      String :uuid, :fixed => true, :size => 4
    end

    U = DB[:uuids]


    def test(msg)
      U.delete
      begin
        puts
        puts "==> #{msg}"
        yield
        puts"<== PASS", U.all.inspect
      rescue
        puts "<== FAIL", $!.inspect
      end
    end

    def for_uuid(uuid)
      print "================ Testing : #{uuid} ==========" 

      test "using 'insert'" do
        U.insert(:uuid => uuid)
      end

      test  "using raw sql" do
        DB.run ("INSERT INTO uuids ('uuid') VALUES('#{uuid}')")
      end

      test  "using prepared statement" do
        U.prepare(:insert, :p, :uuid => :$n)
        DB.call(:p, "n" => uuid)
      end
      puts
      puts

    end

    for_uuid('Helo')
    # Create dodgy string
    for_uuid(["53020100"].pack("H*"))
