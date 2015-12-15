MYSQL          := /usr/local/mysql-5.6.22-osx10.8-x86_64/bin/mysql
MYSQL_USER     := root
SCRIPT         := data-generator.pl
DATE_FROM      := 20150120
DATE_TO        := 20150125
MAX_EMPLOYEES  := 3
MAX_CATEGORIES := 3



inject:
	$(MYSQL) -u $(MYSQL_USER) sales < model.sql
	perl $(SCRIPT) --date-from=$(DATE_FROM) --date-to=$(DATE_TO) --max-employees=$(MAX_EMPLOYEES) --max-categories=$(MAX_CATEGORIES)
	$(MYSQL) -u $(MYSQL_USER) sales < data.sql



