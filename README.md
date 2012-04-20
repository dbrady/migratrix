# Migratrix

Dominate your legacy Rails migrations! Migratrix is a gem to help you
generate and control Migrations, which extract data from legacy systems
and import them into your current one.

## General Info

Migratrix is a framework that supports various migration strategies.
You tell it how you want to connect to a data source, define any
transformations, and then describe the "load target": how and where
you want the new data to come out. You can, of course, extract data
from a legacy database and load it into your all-new database, but you
can also read and write from logs, flat files, or even external
services.

If you can get at the data from Ruby, Migratrix can use it as a source
of extractable data. If you can get at the new storage mechanism from
Ruby, Migratrix can use it as a load target.

You can extract data from an API and load it into your database. You
can extract enumerables from a database and load it to source code
that defines constants for the enumeration.

## Weapons-Grade Migrations

Migratrix tries to keep simple things simple, but really shines when
it scales.

Migratrix is intended to be as simple and easy to use as possible for
small cases, but to have no problems scaling upwards. As a result if
you have an ultra-simple migration that one developer on the team will
only ever run once, Migratrix will work but may not be the best tool.

If, however, you have

* Complex and/or complicated migrations

* Migrations that need to be run more than once, especially if they
  need to be run frequently and/or regularly

* Migrations that need to be run by multiple developers or by
  distributed machines

then your migration strategy is complicated enough that it needs to be
part of the codebase and knowledgebase for your project, and you want
a heavier-duty migration tool. Migratrix is the perfect tool in that
situation.


## Object-Oriented Data Transformation

The first few times you write a special-purpose data migration tool,
you're going to be tempted to just say "here's a hash for the source,
here's a hash for the destination, and here's a function to transform
from one to the other". And it will work. But then the extra
requirements start to roll in:

* We have 20 million rows, can you do the migration in batches?

* We need to split the users table into users and addresses tables,
  how hard is that?

* We have a TON of duplicate data, can you merge it down when you
  migrate?

* Can we just migrate one or two exemplar rows to test the migration
  tool?

And my all-time personal favorite:

* We've decided we want to keep the old site live while the beta site
  is running, can you keep the databases in sync?

I started writing Migratrix when my third client asked me to keep a
legacy site and a beta site synchronized. For me this tool reduced the
problem from "utterly impossible" to "merely very difficult". :-)

As a result, Migratrix is very much object based. You get at a data
source by using an Extract object. If Migratrix does not support the
kind of extraction you want to do, it provides the Extract base class
so you can write your own extractor.

Then the data is handed off to a Transform object, and finally it is
given to a Load object.

Migratrix provides a handful of Extract, Transform and Load classes to
handle common types of migration (reading and writing models with
ActiveRecord, writing YAML files, etc).

## Motivation

So... much... legacy... data....

## Rails and Ruby Requirements

### Rails 3

Migratrix depends on Rails 3 for its ActiveRecord and ActiveSupport
libraries. If your project was written in an older version of Rails,
and you want to use ActiveRecord as your extractor, you may need to
define new models that are compatible with Rails 3. But try just
loading the old models first; as long as the models aren't too
complicated or interconnected, they may work.

### Ruby 1.9.2 or later

Because I can.

## Examples

### ETL

I use the term "ETL" here in a loosely similar mechanism as in data
warehousing: Extract, Transform and Load. Migratrix approaches
migrations in three phases:

* **Extract** The Migration obtains the legacy data from 1 or more sources

* **Transform** The Migration transforms the data into 1 or more outputs

* **Load** The Migration saves the data into the new database or other
output(s)

### General Structure

I like to create a folder structure in db/legacy with a /migrations
folder and a /models folder. Then I write rake tasks to handle the
more common migrations. Migration classes go in /migrations,
naturally; /models is where I store ActiveRecord models that must
access the legacy database. It is important to keep these namespaced
so that your `User`model doesn't conflict with your `Legacy::User`
model.

### Simple Example: Straight-up ActiveRecord Copy

Let's say your legacy app has a simple table that you want to keep
unchanged. Migratrix can bring this over using straight ActiveRecord
copies:

    TODO: Write Sample App so these examples make sense
    TODO: And then come write this example


### Slightly More Complicated: Defining your own extensible class

Let's say your legacy app has a table that stores what amount to
constants in a table in the database. Either the data never changes
(in fact, you don't even have an admin page to edit the data), or the
data changes rarely enough that you're willing to restart the
webserver if the data DOES change. It's also really simple data, and
has no dependencies. For the sake of debmonstration, let's say that
your app stores all 50 US States and their abbreviations. (And you put
it in the database because ONE day you were SURE you were going to
need to add Canadian provinces or Japanese boroughs.)

Let's migrate this to a YAML file and store it in config/constants,
and at boot time we'll write some code to load the states.yml file and
create a frozen hash called MyApp::STATES.

This should be straightforward at this point, but wait. It also turns
out we need to do the same thing with the countries table, the
shipping_carriers table, and about six other tables. They're all the
same: we need to extract from the legacy database and write to a
yaml file in the constants folder.

We can do that. Here's the entire migration for States:

    require 'constants_migration'
    module Legacy
      class StatesMigration < ConstantsMigration
        extend_extraction source: Legacy::State
        extend_transform transform: { id: :id, name: :name, abbreviation: :state_code }
        extend_load filename: MyApp::CONSTANTS_PATH + "states.yml"
      end
    end

And the reason this works is that you've written your own custom
Migration class, which looks like this:

    module Legacy
      # Migrates a Legacy ActiveRecord table through a transform to a
      # constants file. Child classes should extend_extraction with
      # :source, transform with a :transform hash, and load with the
      # filename to write to.
      class ConstantsMigration < Migratrix::Migration
        set_extraction :active_record, source: Model
        set_transform :transform, {
          transform_collection: Hash,
          transform_class:  Hash,
          extract_attribute:  :[],
          apply_attribute: :[]=,
          store_transformed_object: ->(object,collection){  collection[object[:id]] = object }
        }
        set_load :yaml
      end
    end

## Migration Dependencies

Migratrix isn't quite smart enough to know that a migrator depends on
another migrator. (Actually, that's easy. What's hard is knowing if a
dependent migrator has run and is up-to-date. This is a solvable
problem, I just haven't needed to solve it with Migratrix yet.)

## Migration Strategies

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
single record to test a migraton, or grab a few thousand to get an
idea for how long a full migration will take.

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

## Known Limitations and Issues

### Migration Tests

Sorry, nothing to see here yet. Migratrix was originally developed in
an environment where the migrations were so heavy-duty and hairy that
we literally had `legacy_migration_test` and
`legacy_migration_development` databases for migration development.
Migratrix doesn't directly support testing of migrations yet. This is
mostly a note to remind myself that that heavy-duty migrations can and
should be developed in a TDD style, and Migratrix should make this
easy.

### Rake Tasks and/or Rails Generators

Migratrix is definitely a heavyweight tool for migrating data. It
would be nice if the gem provided rake tasks or Rails generators to
help with the boilerplate.

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

## Contributing

YES PLEASE! For bugs and other issues, send a pull request. If you
would like to extend or change a feature of Migratrix, discussion is
also very welcome.


