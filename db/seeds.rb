# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end
# Create run_time_objects associated with users
me = User.find_by(email: "maitreya.niranjan@gmail.com")


run_time_objects = RunTimeObject.create!([
  {
    name: "Object 1",
    description: "This is a description of Object 1.",
    user_id: me.id
  },
  {
    name: "Object 2",
    description: "This is a description of Object 2.",
    user_id: me.id
  },
  {
    name: "Object 3",
    description: "This is a description of Object 3.",
    user_id: me.id
  },
  {
    name: "Object 4",
    description: "This is a description of Object 4.",
    user_id: me.id
  }
])

# Create images associated with run_time_objects
Image.create!([
  {
    tag: "tag_1",
    report: "This is a report for image 1.",
    run_time_object_id: run_time_objects[0].id
  },
  {
    tag: "tag_2",
    report: "This is a report for image 2.",
    run_time_object_id: run_time_objects[1].id
  },
  {
    tag: "tag_3",
    report: "This is a report for image 3.",
    run_time_object_id: run_time_objects[2].id
  }
])

puts "Seeding completed successfully!"