# c50file_generator
generate .names and .data files from .csv

## usage
### ordinary use
`ruby c50file_generator.rb hoge.csv`
### with test data generation
use option `-t <percentage>` for specifing the parcentage of samples for testing data (.test file)  
test data(and also training data) is extracted randomly  
`ruby c50file_generator.rb hoge.csv -t 20`
