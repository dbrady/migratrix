# Migratrix

Dominate your legacy Rails migrations! Migratrix is a gem to help you
generate and control Migrations, which extract data from legacy systems
and import them into your current one.

## Warning: Experimental Developmental In-Progress Stuff

I am currently extracting Migratrix from an ancient legacy codebase.
(Oh the irony.) A lot of the stuff I say Migratrix supports is stuff
that it supports over there, not in here. Be aware that most of this
document is more of a TODO list than a statement of fact. I'll remove
this message once Migratrix does what it says on the tin.

## General Info

Migratrix is a legacy migration tool strategy

## Motivation

So... much... legacy... data....

## Rails and Ruby Requirements

### Rails 3 Only

Migratrix was originally developed under Rails 2, but come on. Rails 2
apps are legacy SOURCES now, not destinations. Migratrix requires
Rails 3. Once everything's in place I'll bump the Migratrix version to
3.x to indicate that Migratrix is in keeping with Rails 3.

### Ruby 1.9

Because I can.

## Example

## ETL

I use the term "ETL" here in a loosely similar mechanism as in data
warehousing: Extract, Transform and Load. Migratrix approaches
migrations in three phases:

* **Extract** The Migration obtains the legacy data from 1 or more
    sources
    
* **Transform** The Migration transforms the data into 1 or more
    outputs
    
* **Load** The Migration saves the data into the new database or other
    output(s)
    

## Migration Dependencies

Migratrix isn't quite smart enough to know that a migrator depends on
another migrator. (Actually, that's easy. What's hard is knowing if a
dependent migrator has run and is up-to-date.)

## Strategies

Migratrix supports multiple migration strategies:

* Straight up ActiveRecord: Given a model class (probably connected to
  a legacy database), a mapping transform and a destination model,
  Migratrix extracts the source models, transforms them and saves
  them. (In Rails 2 this was sometimes dangerous because the entire
  source table(s) would be loaded into memory during the Extract
  phase. In Rails 3 this is no longer a problem, somewhat reducing the
  motivation for the next strategy.)

* Batch Select: Given a SQL query as the extraction source, a
  Migration can pull batches of hashes from the legacy database. You
  give up having legacy model objects in exchange for being able to
  scan massive tables in batches of 1000 or more (or less). In Rails 3
  this is less of a motivation. However, for complicated source
  extractions where a source model does not make sense, this strategy
  is still excellent.

* Pure SQL: If both databases are on the same server, you can often
  migrate data with a +SELECT INTO+ or +INSERT SELECT+ statement. This
  is one of the fastest ways to migrate data because the data never
  comes up into the ruby data space. On the other hand, the migration
  may be more complicated to write because the data can be manipulated
  by ruby--the entire ETL must be handled by the single SQL statement.
  Additionally, it is seriously nontrivial to log the migrated records
  because you have to handle that at the SQL level as well.

## Slices of Data

Migratrix supports taking partial slices of data. You can migrate a
single record to test a migraton, grab 100 records or 1000 to get an
idea for how long a full migration will take, or perform the entire
migration.

## Ongoing Migrations

Migratrix also supports ongoing migrations, which are useful when the
legacy database continues to operate and change after the new Rails
site is live and you cannot remigrate all-new data.

## Migration Log

Migratrix can create a migration log for you. This is a table that
contains the legacy id and table, and the destination id and table. It
can also record the source object, which is useful for debugging or
handling migration cases where legacy records get changed or deleted
after migrating.

## Migration Tests

Sorry, nothing to see here yet. Migratrix was originally developed in
an environment where the migrations were so heavy-duty and hairy that
we literally had `legacy_migration_test` and
`legacy_migration_development` databases for migration development.
Migratrix doesn't directly support testing of migrations yet. This is
mostly a note to remind myself that that heavy-duty migrations can and
should be developed in a TDD style, and Migratrix should make this
easy.

## A note about the name

In old Latin, -or versus -ix endings aren't just about feminine and
masculine. Like old Greek's -a versus -os endings, a masculine ending
usually refers to a small, single instance of a thing while the
feminine refers to the large or collective instance. For example, in
Greek, the masculine word _petros_ means "stone" or "pebble" while the
feminine word _petra_ means "bedrock". More poetically, the feminine
can sometimes be viewed not as a gender mirror, but maternally
instead: the bedrock is what creates or gives birth to stones and
pebbles.

Hence Migratrix is the gem that helps you generate and control your
Migrations, while Migration is the class that defines how a single
set of data, such as a table, a set of models, etc., is migrated.

## License

MIT. See the license file.

## Authors

* David Brady -- github@shinybit.com

