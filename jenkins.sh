# This configuration file is used to test/build the project on Olery's private
# Jenkins instance. Patches containing changes to this file made by people
# outside of Olery will most likely be rejected.

# The name of the project, used for other settings such as the MySQL database
# and the package name.
PROJECT_NAME="oni"

# Whether or not to use a MySQL database, set to a non empty value to enable
# this. Enabling this will tell Jenkins to create/drop the database and to
# import any migrations if needed.
unset USE_MYSQL

# The command to run for the test suite. Junction itself doesn't have a test
# suite so we'll use a noop.
TEST_COMMAND="rake jenkins --trace"
