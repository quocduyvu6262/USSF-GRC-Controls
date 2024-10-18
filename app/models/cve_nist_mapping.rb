class CveNistMapping < ApplicationRecord
  serialize :nist_control_identifiers, coder: JSON
end