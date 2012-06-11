# Yes we could have use rake, but rake is so slow and verbose ...
# Look at this as a collection of shell commands.

.PHONY: migrate_test test doc

test:
	bundle exec rspec

doc:
	bundle exec yardoc

migrate_test:
	bundle exec sequel -m db/migrations -e test config/database.yml

show:
	bundle exec showoff serve showoff/core-2012-06-11

