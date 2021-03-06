#!/usr/bin/env bash

script_dir=$(cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
script_name=$0

# This is a test script designed to test that everything works in the various
# accessory scripts in this package. Parameters used have absolutely NO
# relation to best practice and this should not be taken as a sensible
# parameterisation for a workflow.

function usage {
    echo "usage: $script_name [action] [use_existing_outputs]"
    echo "  - action: what action to take, 'test' or 'clean'"
    echo "  - use_existing_outputs, 'true' or 'false'"
    exit 1
}

action=${1:-'test'}
use_existing_outputs=${2:-'false'}

if [ "$action" != 'test' ] && [ "$action" != 'clean' ]; then
    echo "Invalid action"
    usage
fi

if [ "$use_existing_outputs" != 'true' ] && [ "$use_existing_outputs" != 'false' ]; then
    echo "Invalid value ($use_existing_outputs) for 'use_existing_outputs'"
    usage
fi

test_matrix_url="https://raw.githubusercontent.com/jdblischak/singleCellSeq/master/data/molecules.txt"
test_annotation_url="https://raw.githubusercontent.com/jdblischak/singleCellSeq/master/data/annotation.txt"

test_working_dir=`pwd`/'post_install_tests'
export test_matrix_file=$test_working_dir/test_data/`basename $test_matrix_url`
export test_annotation_file=$test_working_dir/test_data/`basename $test_annotation_url`

# Clean up if specified

if [ "$action" = 'clean' ]; then
    echo "Cleaning up $test_working_dir ..."
    rm -rf $test_working_dir
    exit 0
elif [ "$action" != 'test' ]; then
    echo "Invalid action '$action' supplied"
    exit 1
fi 

# Initialise directories

output_dir=$test_working_dir/outputs
data_dir=$test_working_dir/test_data

mkdir -p $test_working_dir
mkdir -p $output_dir
mkdir -p $data_dir

################################################################################
# Fetch test data 
################################################################################

if [ ! -e "$test_matrix_file" ]; then
    wget $test_matrix_url -P $data_dir
    wget $test_annotation_url -P $data_dir
fi

################################################################################
# List tool outputs/ inputs
################################################################################

export raw_singlecellexperiment_object="$output_dir/raw_sce.rds"
export random_genes_file="$output_dir/random_genes.txt"
export random_cells_file="$output_dir/random_cells.txt"

## Test parameters- would form config file in real workflow. DO NOT use these
## as default values without being sure what they mean.

export n_random_genes=20
export n_random_cells=100

################################################################################
# Test individual scripts
################################################################################

# Make the script options available to the tests so we can skip tests e.g.
# where one of a chain has completed successfullly.

export use_existing_outputs

# Derive the tests file name from the script name

tests_file="${script_name%.*}".bats

# Execute the bats tests

$tests_file
