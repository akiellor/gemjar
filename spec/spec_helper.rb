$CLASSPATH << Dir[File.join(File.expand_path(File.join(File.dirname(__FILE__), "..", "vendor")), "*")]

require 'nokogiri'

RSpec::Matchers.define :be_valid_xml do |schema|
  match do |doc|
    xsd = Nokogiri::XML::Schema(schema)

    @errors = xsd.validate(Nokogiri::XML(doc))

    doc.include?("<") && @errors.empty?
  end

  failure_message_for_should do
    document = Nokogiri::XML(schema)
    schema_node = document.xpath("/xs:schema", document.root.namespaces).first
    "expected to be valid (#{schema_node.attributes['targetNamespace']}), but was not: \n\n#{@errors.join("\n")}"
  end
end

RSpec::Matchers.define :have_xpath_value do |xpath, expected_value|
  match do |doc|
    document = Nokogiri::XML(doc)
    document.xpath(xpath, document.root.namespaces).text == expected_value
  end
end
