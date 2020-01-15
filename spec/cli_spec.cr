require "./spec_helper"
require "../src/main"

describe "Command line interface" do
  # This is needed because we use the database URI as key to store the last query.
  it "transform postgresql:// URIs into postgres://" do
    detect_database("postgresql://localhost/foo").should eq("postgres://localhost/foo")
    detect_database("postgres://localhost/foo").should eq("postgres://localhost/foo")
  end
end
