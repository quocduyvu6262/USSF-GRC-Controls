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
require 'csv'

User.find_or_create_by!(
  email: "testuser@gmail.com",
)
me = User.find_by(email: "testuser@gmail.com")
puts me.inspect  # This will output the user or nil if not found
Image.destroy_all
RunTimeObject.destroy_all


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
# Image.create!([
#   {
#     tag: "image 1",
#     report: "This is a report for image 1.",
#     run_time_object_id: run_time_objects[0].id
#   },
#   {
#     tag: "image 2",
#     report: "This is a report for image 2.",
#     run_time_object_id: run_time_objects[0].id
#   },
#   {
#     tag: "image 3",
#     report: "This is a report for image 3.",
#     run_time_object_id: run_time_objects[0].id
#   },
#   {
#     tag: "image 4",
#     report: "This is a report for image 4.",
#     run_time_object_id: run_time_objects[0].id
#   },
#   {
#     tag: "image 5",
#     report: "This is a report for image 5.",
#     run_time_object_id: run_time_objects[0].id
#   },
#   {
#     tag: "image 6",
#     report: "This is a report for image 6.",
#     run_time_object_id: run_time_objects[0].id
#   },
#   {
#     tag: "image 7",
#     report: "This is a report for image 7.",
#     run_time_object_id: run_time_objects[0].id
#   },
#   {
#     tag: "image 8",
#     report: "This is a report for image 8.",
#     run_time_object_id: run_time_objects[0].id
#   }
# ])

CveNistMapping.delete_all
csv_file_path = Rails.root.join('db', 'seeds', 'cve_nist_mappings.csv')

CSV.foreach(csv_file_path, headers: true) do |row|
  CveNistMapping.create!(
    cve_id: row['cve_id'],
    nist_control_identifiers: row['nist_control_identifiers'].split(',')
  )
end

puts "Seeding completed successfully!"
