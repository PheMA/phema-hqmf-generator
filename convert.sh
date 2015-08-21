cd ../health-data-standards
rake hqmf:parse[../phema-hqmf-generator/test.xml,2]
cp ./tmp/json/test.xml.json ../phema-hqmf-generator
cd ../phema-hqmf-generator
