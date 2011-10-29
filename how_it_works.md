# How It Works

Migratrix migrates data from one data storage system to another.

It does this in three phases: Extract, Transform, and Load.

## Extract

The Extract phase extracts data from a legacy data storage system.
Typically this will be a Rails database, but it can be anything that
supplies a set of data.

In Migratrix, Extraction objects are usually quite simple, but rely on
you writing Legacy ActiveRecord classes that can talk to the legacy
database, which can be quite tricky. See the examples section if one
ever comes into existence.

## Transform

The Transform phase converts the data into a format that your system
likes. In its simplest form it might grab a legacy object and copy its
attributes into a new object. In trickier migrations you have more
complicated transforms. For example, your legacy data might have
home and business addresses stored as fields on the customer object,
while you new system has Customer and Address objects. The Transform
would take the extracted Customer and produce the Customer, Address
(home) and Address (business) objects.

The transform object will probably always be the most complicated bit
of code in your migration, because it does all the heavy lifting.

## Load

The Load phase loads this data up into your new database. This name
can be tricky because usually we think of "Save" here, but the "ETL"
terminology comes from data warehousing, and more importantly you
might not actually be saving records to a database. For example, you
might write a migration that saves an enum table to a yaml file to be
loaded up as a set of constants.

The load object is typically the simplest. In fact, if your
transformed objects respond to the `save()` method, all you have
to do is specify a generic load and you're done.

